#!/usr/bin/env python3
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Dict, Iterable, Optional


STATUS_PATTERN = re.compile(r'"\s*(\d{3})\s')


def extract_status(line: str) -> Optional[int]:
  """Return HTTP status code from a log line, if found."""
  match = STATUS_PATTERN.search(line)
  if match:
    try:
      return int(match.group(1))
    except ValueError:
      return None
  return None


def process_log(path: str) -> Dict[str, int]:
  """
  Count requests per HTTP status code.

  Args:
      path: Path to access.log. Use "-" to read from STDIN.
  """
  counts = Counter()
  lines: Iterable[str]
  fh = None

  if path == "-" or path is None:
    lines = sys.stdin
  else:
    file_path = Path(path)
    if not file_path.exists():
      raise FileNotFoundError(path)
    fh = file_path.open()
    lines = fh

  try:
    for line in lines:
      status = extract_status(line)
      if status is None:
        continue
      counts[status] += 1
  finally:
    if fh:
      fh.close()

  return {str(code): count for code, count in sorted(counts.items())}


if __name__ == "__main__":
  target = sys.argv[1] if len(sys.argv) > 1 else "access.log"
  result = process_log(target)
  print(json.dumps(result, indent=2))
