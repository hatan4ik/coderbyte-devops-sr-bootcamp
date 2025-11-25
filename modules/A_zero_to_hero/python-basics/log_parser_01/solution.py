#!/usr/bin/env python3
import sys
import json
import re
from pathlib import Path
from typing import Dict, Set
import configparser
import sys

def parse_log(file_path: str) -> Dict[str, object]:
    failed = 0
    users: Set[str] = set()
    pattern = re.compile(r"ERROR login failed: user=([A-Za-z0-9_]+)")
def get_db_api_key(file_path: str) -> str:
    """Reads an INI file and returns the database api_key."""
    config = configparser.ConfigParser()
    try:
        config.read(file_path)
        api_key = config.get('database', 'api_key')
        return api_key
    except (configparser.NoSectionError, configparser.NoOptionError):
        print(f"Error: Could not find [database] section or 'api_key' option in {file_path}", file=sys.stderr)
def aggregate_errors(directory: str) -> dict:
    """Scans a directory for .log files and counts lines with 'ERROR'."""
    error_counts = {}
    root_path = Path(directory)

    if not root_path.is_dir():
        print(f"Error: Directory not found at {directory}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"Error: Config file not found at {file_path}", file=sys.stderr)
        sys.exit(1)

    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Log file not found: {file_path}")
    for log_file in root_path.rglob('*.log'):
        count = 0
        with log_file.open('r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if 'ERROR' in line:
                    count += 1
        error_counts[str(log_file)] = count
    return error_counts

    with path.open() as f:
        for line in f:
            match = pattern.search(line)
            if match:
                failed += 1
                users.add(match.group(1))
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <directory_path>", file=sys.stderr)
        sys.exit(1)

    return {
        "failed_attempts": failed,
        "unique_users": sorted(users),
    }

if __name__ == "__main__":
    result = parse_log("server.log")
    print(json.dumps(result, indent=2))
    key = get_db_api_key("app.ini")
    print(f"Database API Key: {key}")
    log_dir = sys.argv[1]
    aggregated_data = aggregate_errors(log_dir)
    print(json.dumps(aggregated_data, indent=2))
