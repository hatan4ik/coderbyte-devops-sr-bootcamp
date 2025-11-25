#!/usr/bin/env python3
import sys
import json
from collections import Counter

def process_log(path: str) -> dict:
  counts = Counter()
  with open(path) as f:
    for line in f:
      parts = line.strip().split()
      if not parts:
        continue
      # naive: assume status code 9th field like common log format
      try:
        status = int(parts[8])
      except (IndexError, ValueError):
        continue
      counts[status] += 1
  return {str(k): v for k, v in sorted(counts.items())}

if __name__ == "__main__":
  if len(sys.argv) < 2:
    print("Usage: log_processor.py <access.log>", file=sys.stderr)
    sys.exit(1)
  result = process_log(sys.argv[1])
  print(json.dumps(result, indent=2))
