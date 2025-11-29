#!/usr/bin/env python3
"""FAANG-Grade Web Scraper with Async, Rate Limiting, and Circuit Breaker"""

import asyncio
import sys
from dataclasses import dataclass
from enum import Enum
from typing import Optional
from urllib.parse import urljoin, urlparse

import aiohttp
from bs4 import BeautifulSoup
import structlog

log = structlog.get_logger()

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"

@dataclass
class CircuitBreaker:
    failure_threshold: int = 3
    failures: int = 0
    state: CircuitState = CircuitState.CLOSED
    
    def record_success(self):
        self.failures = 0
        self.state = CircuitState.CLOSED
    
    def record_failure(self):
        self.failures += 1
        if self.failures >= self.failure_threshold:
            self.state = CircuitState.OPEN

@dataclass(frozen=True)
class ScrapedData:
    url: str
    title: str
    links: list[dict]
    images: list[str]
    status_code: int

@dataclass
class RateLimiter:
    rate: float = 1.0  # requests per second
    
    async def acquire(self):
        await asyncio.sleep(1.0 / self.rate)

@dataclass
class FAANGWebScraper:
    timeout: float = 10.0
    rate_limiter: RateLimiter = None
    circuit_breaker: CircuitBreaker = None
    
    def __post_init__(self):
        if self.rate_limiter is None:
            self.rate_limiter = RateLimiter(rate=2.0)
        if self.circuit_breaker is None:
            self.circuit_breaker = CircuitBreaker()
    
    async def scrape(self, url: str) -> Optional[ScrapedData]:
        if self.circuit_breaker.state == CircuitState.OPEN:
            log.error("circuit_breaker_open", url=url)
            return None
        
        parsed = urlparse(url)
        if not parsed.scheme or not parsed.netloc:
            log.error("invalid_url", url=url)
            return None
        
        await self.rate_limiter.acquire()
        
        try:
            async with aiohttp.ClientSession() as session:
                timeout = aiohttp.ClientTimeout(total=self.timeout)
                async with session.get(url, timeout=timeout) as resp:
                    html = await resp.text()
                    
                    soup = BeautifulSoup(html, 'html.parser')
                    
                    title = soup.find('title')
                    title_text = title.text.strip() if title else "No title"
                    
                    links = []
                    for link in soup.find_all('a', href=True)[:50]:
                        href = urljoin(url, link['href'])
                        text = link.text.strip()[:100]
                        links.append({'text': text, 'href': href})
                    
                    images = [urljoin(url, img['src']) for img in soup.find_all('img', src=True)[:50]]
                    
                    self.circuit_breaker.record_success()
                    
                    log.info("scrape_success", url=url, links=len(links), images=len(images))
                    
                    return ScrapedData(
                        url=url,
                        title=title_text,
                        links=links,
                        images=images,
                        status_code=resp.status
                    )
        
        except asyncio.TimeoutError:
            self.circuit_breaker.record_failure()
            log.error("scrape_timeout", url=url)
            return None
        except Exception as e:
            self.circuit_breaker.record_failure()
            log.error("scrape_failed", url=url, error=str(e))
            return None

async def main(args: list[str]) -> int:
    if len(args) < 2:
        print("Usage: web_scraper_faang.py <url>", file=sys.stderr)
        return 1
    
    url = args[1]
    
    scraper = FAANGWebScraper(timeout=10.0)
    data = await scraper.scrape(url)
    
    if not data:
        return 1
    
    print(f"Title: {data.title}")
    print(f"Status: {data.status_code}")
    print(f"Links: {len(data.links)}")
    print(f"Images: {len(data.images)}")
    
    print("\nTop 10 Links:")
    for i, link in enumerate(data.links[:10], 1):
        print(f"  {i}. {link['text'][:50]} -> {link['href']}")
    
    return 0

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(asyncio.run(main(sys.argv)))
