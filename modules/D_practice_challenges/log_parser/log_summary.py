#!/usr/bin/env python3
import sys
import json

def summarize(path: str) -> dict:
    total = errors = warnings = 0
    with open(path) as f:
        for line in f:
            total += 1
            if "ERROR" in line:
                errors += 1
            if "WARN" in line or "WARNING" in line:
                warnings += 1
    return {"total": total, "errors": errors, "warnings": warnings}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: log_summary.py <logfile>", file=sys.stderr)
        sys.exit(1)
    res = summarize(sys.argv[1])
    print(json.dumps(res, indent=2))
