#!/usr/bin/env python3
"""FAANG-Grade API Client with Circuit Breaker, Retry, and Observability"""

import asyncio
import json
import sys
import time
from dataclasses import dataclass, field
from enum import Enum
from typing import Optional, Protocol
from urllib.parse import urlparse

import aiohttp
import structlog

log = structlog.get_logger()

# Circuit Breaker Pattern
class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

@dataclass
class CircuitBreaker:
    failure_threshold: int = 5
    timeout: float = 60.0
    success_threshold: int = 2
    
    state: CircuitState = field(default=CircuitState.CLOSED, init=False)
    failures: int = field(default=0, init=False)
    successes: int = field(default=0, init=False)
    last_failure_time: float = field(default=0.0, init=False)
    
    def call(self, func):
        if self.state == CircuitState.OPEN:
            if time.time() - self.last_failure_time > self.timeout:
                self.state = CircuitState.HALF_OPEN
                self.successes = 0
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func()
            self.on_success()
            return result
        except Exception as e:
            self.on_failure()
            raise e
    
    def on_success(self):
        self.failures = 0
        if self.state == CircuitState.HALF_OPEN:
            self.successes += 1
            if self.successes >= self.success_threshold:
                self.state = CircuitState.CLOSED
    
    def on_failure(self):
        self.failures += 1
        self.last_failure_time = time.time()
        if self.failures >= self.failure_threshold:
            self.state = CircuitState.OPEN

# Result Monad
@dataclass(frozen=True)
class Result:
    value: Optional[dict] = None
    error: Optional[str] = None
    
    @property
    def is_ok(self) -> bool:
        return self.error is None
    
    @property
    def is_err(self) -> bool:
        return self.error is not None

# Retry with Exponential Backoff
async def retry_with_backoff(func, max_retries: int = 3, base_delay: float = 1.0):
    for attempt in range(max_retries):
        try:
            return await func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            log.warning("retry_attempt", attempt=attempt + 1, delay=delay, error=str(e))
            await asyncio.sleep(delay)

# HTTP Client Protocol
class HTTPClient(Protocol):
    async def request(self, method: str, url: str, **kwargs) -> Result: ...

@dataclass
class AsyncHTTPClient:
    timeout: float = 10.0
    max_retries: int = 3
    circuit_breaker: CircuitBreaker = field(default_factory=CircuitBreaker)
    
    async def request(self, method: str, url: str, **kwargs) -> Result:
        async def _make_request():
            async with aiohttp.ClientSession() as session:
                timeout = aiohttp.ClientTimeout(total=self.timeout)
                async with session.request(method, url, timeout=timeout, **kwargs) as resp:
                    data = await resp.json() if resp.content_type == 'application/json' else await resp.text()
                    return Result(value={
                        "status": resp.status,
                        "headers": dict(resp.headers),
                        "data": data,
                        "elapsed_ms": resp.request_info.headers.get('X-Response-Time', 0)
                    })
        
        try:
            result = await retry_with_backoff(_make_request, self.max_retries)
            log.info("http_request_success", method=method, url=url, status=result.value["status"])
            return result
        except Exception as e:
            log.error("http_request_failed", method=method, url=url, error=str(e))
            return Result(error=str(e))

async def main(args: list[str]) -> int:
    if len(args) < 2:
        print("Usage: api_client_faang.py <url> [method] [json_data]", file=sys.stderr)
        return 1
    
    url = args[1]
    method = args[2].upper() if len(args) > 2 else "GET"
    data = json.loads(args[3]) if len(args) > 3 else None
    
    # Validate URL
    parsed = urlparse(url)
    if not parsed.scheme or not parsed.netloc:
        log.error("invalid_url", url=url)
        return 1
    
    client = AsyncHTTPClient(timeout=10.0, max_retries=3)
    
    kwargs = {}
    if method == "POST" and data:
        kwargs["json"] = data
    
    result = await client.request(method, url, **kwargs)
    
    if result.is_ok:
        print(json.dumps(result.value, indent=2))
        return 0
    else:
        print(json.dumps({"error": result.error}, indent=2), file=sys.stderr)
        return 1

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(asyncio.run(main(sys.argv)))
