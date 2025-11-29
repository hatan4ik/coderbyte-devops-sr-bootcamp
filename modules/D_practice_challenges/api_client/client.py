#!/usr/bin/env python3
import sys
import json
import requests

def fetch_active_ids(url: str):
    resp = requests.get(url, timeout=5)
    resp.raise_for_status()
    data = resp.json()
    if not isinstance(data, list):
        raise ValueError("Expected list")
    return [item["id"] for item in data if item.get("active") is True]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: client.py <url>", file=sys.stderr)
        sys.exit(1)
    ids = fetch_active_ids(sys.argv[1])
    print(json.dumps(ids))
