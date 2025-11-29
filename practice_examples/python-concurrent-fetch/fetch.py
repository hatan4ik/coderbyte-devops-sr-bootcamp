#!/usr/bin/env python3
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from typing import List, Dict, Any
from urllib import request, error

DEFAULT_TIMEOUT = 5
MAX_WORKERS = 8


@dataclass
class FetchResult:
    url: str
    status: int
    elapsed_ms: float
    error: str = ""


def fetch_once(url: str, timeout: int) -> FetchResult:
    start = time.time()
    try:
        with request.urlopen(url, timeout=timeout) as resp:
            status = resp.getcode()
    except Exception as exc:  # noqa: BLE001 broad for network errors
        return FetchResult(url=url, status=0, elapsed_ms=(time.time() - start) * 1000, error=str(exc))
    else:
        return FetchResult(url=url, status=status, elapsed_ms=(time.time() - start) * 1000)


def fetch_with_retry(url: str, timeout: int, retries: int = 1) -> FetchResult:
    result = fetch_once(url, timeout)
    if result.status == 0 and retries > 0:
        return fetch_with_retry(url, timeout, retries=retries - 1)
    return result


def run(urls: List[str], timeout: int = DEFAULT_TIMEOUT) -> Dict[str, Any]:
    summary: Dict[str, Any] = {
        "total": len(urls),
        "success": 0,
        "failure": 0,
        "results": [],
    }

    with ThreadPoolExecutor(max_workers=min(MAX_WORKERS, len(urls) or 1)) as pool:
        future_map = {pool.submit(fetch_with_retry, url, timeout): url for url in urls}
        for future in as_completed(future_map):
            res = future.result()
            summary["results"].append({
                "url": res.url,
                "status": res.status,
                "elapsed_ms": round(res.elapsed_ms, 2),
                "error": res.error,
            })
            if res.status and 200 <= res.status < 400:
                summary["success"] += 1
            else:
                summary["failure"] += 1
    return summary


def main(argv: List[str]) -> int:
    urls = argv[1:]
    if not urls:
        print(f"Usage: {argv[0]} <url1> [url2 ...]", file=sys.stderr)
        return 1
    result = run(urls)
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
