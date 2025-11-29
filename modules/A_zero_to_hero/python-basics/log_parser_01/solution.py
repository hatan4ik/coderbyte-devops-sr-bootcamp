#!/usr/bin/env python3
import json
import re
import sys
import argparse
from pathlib import Path
from typing import Dict, Set

def parse_log(file_path: str) -> Dict[str, object]:
    """
    Parses a log file for failed login attempts and returns aggregated data.
    """
    failed = 0
    users: Set[str] = set()
    # A more specific regex to avoid false positives.
    pattern = re.compile(r"ERROR login failed: user=([A-Za-z0-9_]+)")

    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Log file not found: {file_path}")

    try:
        with path.open(encoding="utf-8", errors="ignore") as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    failed += 1
                    users.add(match.group(1))
    except IOError as e:
        print(f"Error reading file {file_path}: {e}", file=sys.stderr)
        sys.exit(1)

    return {
        "failed_attempts": failed,
        "unique_users": sorted(users),
    }

def main():
    """Main entry point for the script."""
    parser = argparse.ArgumentParser(description="Parse a server log for failed login attempts.")
    parser.add_argument("logfile", help="Path to the log file to analyze.")
    args = parser.parse_args()

    result = parse_log(args.logfile)
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
