#!/usr/bin/env python3
import json
import re
from pathlib import Path
from typing import Dict, Set

def parse_log(file_path: str) -> Dict[str, object]:
    failed = 0
    users: Set[str] = set()
    pattern = re.compile(r"ERROR login failed: user=([A-Za-z0-9_]+)")

    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Log file not found: {file_path}")

    with path.open() as f:
        for line in f:
            match = pattern.search(line)
            if match:
                failed += 1
                users.add(match.group(1))

    return {
        "failed_attempts": failed,
        "unique_users": sorted(users),
    }

if __name__ == "__main__":
    result = parse_log("server.log")
    print(json.dumps(result, indent=2))
