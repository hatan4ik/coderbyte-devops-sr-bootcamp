#!/usr/bin/env python3
import sys
import json
from pathlib import Path

def aggregate_errors(directory: str) -> dict:
    """Scans a directory for .log files and counts lines with 'ERROR'."""
    error_counts = {}
    root_path = Path(directory)

    if not root_path.is_dir():
        print(f"Error: Directory not found at {directory}", file=sys.stderr)
        sys.exit(1)

    for log_file in root_path.rglob('*.log'):
        count = 0
        with log_file.open('r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if 'ERROR' in line:
                    count += 1
        error_counts[str(log_file)] = count
    return error_counts

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <directory_path>", file=sys.stderr)
        sys.exit(1)

    log_dir = sys.argv[1]
    aggregated_data = aggregate_errors(log_dir)
    print(json.dumps(aggregated_data, indent=2))