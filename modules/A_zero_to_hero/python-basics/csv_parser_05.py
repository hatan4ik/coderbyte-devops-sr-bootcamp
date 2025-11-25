#!/usr/bin/env python3
"""CSV Parser - Parse and analyze CSV data"""

import csv
import sys
from collections import defaultdict

def parse_csv(filename):
    if not filename:
        print("Usage: python csv_parser_05.py <csv_file>")
        return
    
    try:
        with open(filename, 'r') as f:
            reader = csv.DictReader(f)
            rows = list(reader)
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        return
    except Exception as e:
        print(f"Error parsing CSV: {e}")
        return
    
    if not rows:
        print("No data found in CSV")
        return
    
    print(f"Total rows: {len(rows)}")
    print(f"Columns: {list(rows[0].keys())}")
    
    # Basic statistics for numeric columns
    numeric_stats = defaultdict(list)
    for row in rows:
        for key, value in row.items():
            try:
                numeric_stats[key].append(float(value))
            except ValueError:
                pass
    
    if numeric_stats:
        print("\nNumeric column statistics:")
        for column, values in numeric_stats.items():
            avg = sum(values) / len(values)
            print(f"  {column}: avg={avg:.2f}, min={min(values)}, max={max(values)}")

if __name__ == "__main__":
    parse_csv(sys.argv[1] if len(sys.argv) > 1 else None)