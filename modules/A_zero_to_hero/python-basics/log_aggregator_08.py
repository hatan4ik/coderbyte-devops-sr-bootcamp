#!/usr/bin/env python3
"""Log Aggregator - Aggregate logs from multiple files"""

import sys
import glob
import re
from datetime import datetime
from collections import defaultdict

def aggregate_logs(pattern):
    if not pattern:
        print("Usage: python log_aggregator_08.py <file_pattern>")
        return
    
    files = glob.glob(pattern)
    if not files:
        print(f"No files found matching pattern: {pattern}")
        return
    
    all_logs = []
    error_counts = defaultdict(int)
    
    for filename in files:
        try:
            with open(filename, 'r') as f:
                for line_num, line in enumerate(f, 1):
                    line = line.strip()
                    if line:
                        all_logs.append({
                            'file': filename,
                            'line': line_num,
                            'content': line,
                            'timestamp': extract_timestamp(line)
                        })
                        
                        if re.search(r'\bERROR\b', line, re.IGNORECASE):
                            error_counts[filename] += 1
        except Exception as e:
            print(f"Error reading {filename}: {e}")
    
    print(f"Processed {len(files)} files, {len(all_logs)} log entries")
    
    if error_counts:
        print("\nError counts by file:")
        for filename, count in error_counts.items():
            print(f"  {filename}: {count} errors")

def extract_timestamp(line):
    # Simple timestamp extraction
    timestamp_pattern = r'\d{4}-\d{2}-\d{2}[\s\T]\d{2}:\d{2}:\d{2}'
    match = re.search(timestamp_pattern, line)
    return match.group() if match else None

if __name__ == "__main__":
    aggregate_logs(sys.argv[1] if len(sys.argv) > 1 else None)