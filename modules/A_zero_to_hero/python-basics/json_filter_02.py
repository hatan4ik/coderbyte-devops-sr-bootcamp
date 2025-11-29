#!/usr/bin/env python3
"""JSON Filter - Filter JSON data based on criteria"""

import json
import sys

def filter_json(filename, key=None, value=None):
    if not filename:
        print("Usage: python json_filter_02.py <json_file> [key] [value]")
        return
    
    try:
        with open(filename, 'r') as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error: {e}")
        return
    
    if isinstance(data, list):
        if key and value:
            filtered = [item for item in data if item.get(key) == value]
        else:
            filtered = data
        
        print(f"Total items: {len(data)}")
        print(f"Filtered items: {len(filtered)}")
        print(json.dumps(filtered, indent=2))
    else:
        print(json.dumps(data, indent=2))

if __name__ == "__main__":
    args = sys.argv[1:]
    filter_json(
        args[0] if len(args) > 0 else None,
        args[1] if len(args) > 1 else None,
        args[2] if len(args) > 2 else None
    )