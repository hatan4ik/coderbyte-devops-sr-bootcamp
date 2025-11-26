# Python: Concurrent Fetcher

Fetch multiple URLs concurrently with timeouts, simple retries, and JSON summary output.

## Usage
```bash
python fetch.py https://example.com https://httpbin.org/status/404
```
Outputs JSON with counts and per-URL status/latency.

## Test
```bash
python tests.py
```
