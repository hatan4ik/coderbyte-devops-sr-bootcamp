#!/usr/bin/env python3
"""FAANG-Grade Concurrency with Asyncio and Structured Logging"""

import asyncio
import sys
import time
from dataclasses import dataclass

import aiohttp
import structlog

log = structlog.get_logger()

@dataclass(frozen=True)
class TaskResult:
    task_id: int
    duration_ms: float
    success: bool
    error: str = ""

async def worker_task(task_id: int, duration: float = 1.0) -> TaskResult:
    """Async worker task"""
    start = time.time()
    log.info("task_started", task_id=task_id)
    
    try:
        await asyncio.sleep(duration)
        elapsed = (time.time() - start) * 1000
        log.info("task_completed", task_id=task_id, duration_ms=round(elapsed, 2))
        return TaskResult(task_id=task_id, duration_ms=elapsed, success=True)
    except Exception as e:
        elapsed = (time.time() - start) * 1000
        log.error("task_failed", task_id=task_id, error=str(e))
        return TaskResult(task_id=task_id, duration_ms=elapsed, success=False, error=str(e))

async def fetch_url(url: str, session: aiohttp.ClientSession) -> TaskResult:
    """Async HTTP fetch"""
    start = time.time()
    
    try:
        async with session.get(url, timeout=aiohttp.ClientTimeout(total=5)) as resp:
            await resp.text()
            elapsed = (time.time() - start) * 1000
            log.info("fetch_success", url=url, status=resp.status, duration_ms=round(elapsed, 2))
            return TaskResult(task_id=hash(url), duration_ms=elapsed, success=True)
    except Exception as e:
        elapsed = (time.time() - start) * 1000
        log.error("fetch_failed", url=url, error=str(e))
        return TaskResult(task_id=hash(url), duration_ms=elapsed, success=False, error=str(e))

async def demo_async_tasks():
    """Demo async task execution"""
    log.info("demo_started", demo="async_tasks")
    start = time.time()
    
    tasks = [worker_task(i, 1.0) for i in range(5)]
    results = await asyncio.gather(*tasks)
    
    elapsed = time.time() - start
    success_count = sum(1 for r in results if r.success)
    
    log.info("demo_completed", demo="async_tasks", 
             duration=round(elapsed, 2), 
             success=success_count, 
             total=len(results))

async def demo_concurrent_requests():
    """Demo concurrent HTTP requests"""
    log.info("demo_started", demo="concurrent_requests")
    start = time.time()
    
    urls = [
        "https://httpbin.org/delay/1",
        "https://httpbin.org/status/200",
        "https://httpbin.org/json"
    ]
    
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(url, session) for url in urls]
        results = await asyncio.gather(*tasks)
    
    elapsed = time.time() - start
    success_count = sum(1 for r in results if r.success)
    
    log.info("demo_completed", demo="concurrent_requests",
             duration=round(elapsed, 2),
             success=success_count,
             total=len(results))

async def main() -> int:
    await demo_async_tasks()
    await demo_concurrent_requests()
    return 0

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(asyncio.run(main()))
