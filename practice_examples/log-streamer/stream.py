#!/usr/bin/env python3
import concurrent.futures
import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

ERROR_PATTERN = re.compile(r"ERROR", re.IGNORECASE)


def count_errors(path: Path) -> Tuple[str, int, int]:
    total_lines = 0
    error_lines = 0
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            total_lines += 1
            if ERROR_PATTERN.search(line):
                error_lines += 1
    return str(path), total_lines, error_lines


def run(paths: List[str]) -> Dict:
    files = [Path(p) for p in paths]
    for p in files:
        if not p.exists():
            raise FileNotFoundError(p)

    results: Dict[str, Dict[str, int]] = {}
    total_errors = 0
    total_lines = 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=min(8, len(files) or 1)) as pool:
        futures = {pool.submit(count_errors, p): p for p in files}
        for future in concurrent.futures.as_completed(futures):
            fname, lines, errors = future.result()
            results[fname] = {"lines": lines, "errors": errors}
            total_lines += lines
            total_errors += errors

    return {
        "files": results,
        "total_lines": total_lines,
        "total_errors": total_errors,
    }


def main(argv: List[str]) -> int:
    if len(argv) < 2:
        print(f"Usage: {argv[0]} <log1> [log2 ...]", file=sys.stderr)
        return 1
    data = run(argv[1:])
    print(json.dumps(data, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
