#!/usr/bin/env python3
"""Production log parser with comprehensive error handling."""
import json
import re
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

LOG_PATTERN = re.compile(
    r'(?P<timestamp>\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+'
    r'(?P<level>INFO|WARNING|ERROR|CRITICAL|DEBUG)\s+'
    r'(?P<message>.*)'
)

def parse_log_file(filepath):
    """Parse log file and return structured summary."""
    if not Path(filepath).exists():
        raise FileNotFoundError(f"Log file not found: {filepath}")
    
    stats = defaultdict(int)
    errors = []
    warnings = []
    
    with open(filepath) as f:
        for line_num, line in enumerate(f, 1):
            match = LOG_PATTERN.match(line.strip())
            if not match:
                continue
            
            level = match.group('level')
            message = match.group('message')
            timestamp = match.group('timestamp')
            
            stats[level] += 1
            
            if level == 'ERROR':
                errors.append({"line": line_num, "timestamp": timestamp, "message": message})
            elif level == 'WARNING':
                warnings.append({"line": line_num, "timestamp": timestamp, "message": message})
    
    return {
        "summary": dict(stats),
        "total_lines": sum(stats.values()),
        "errors": errors[-10:],
        "warnings": warnings[-10:],
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python solution.py <logfile>")
        sys.exit(1)
    
    try:
        result = parse_log_file(sys.argv[1])
        print(json.dumps(result, indent=2))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
