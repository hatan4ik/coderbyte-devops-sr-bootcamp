#!/usr/bin/env python3
"""Log Parser - Parse log files and extract error patterns"""

import sys
import re
from collections import Counter

def parse_log(filename):
    if not filename:
        print("Usage: python log_parser_01.py <log_file>")
        return
    
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        return
    
    errors = []
    warnings = []
    
    for line in lines:
        if re.search(r'\bERROR\b', line, re.IGNORECASE):
            errors.append(line.strip())
        elif re.search(r'\bWARN(ING)?\b', line, re.IGNORECASE):
            warnings.append(line.strip())
    
    print(f"Total lines: {len(lines)}")
    print(f"Errors: {len(errors)}")
    print(f"Warnings: {len(warnings)}")
    
    if errors:
        print("\nRecent errors:")
        for error in errors[-5:]:
            print(f"  {error}")

if __name__ == "__main__":
    parse_log(sys.argv[1] if len(sys.argv) > 1 else None)