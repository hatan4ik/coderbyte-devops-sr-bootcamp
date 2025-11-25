#!/bin/bash
# JSON Parsing with jq - Extract data from JSON files

if [ $# -eq 0 ]; then
    echo "Usage: $0 <json_file> [jq_filter]"
    exit 1
fi

json_file="$1"
filter="${2:-.}"

if [ ! -f "$json_file" ]; then
    echo "Error: JSON file '$json_file' not found"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed"
    exit 1
fi

echo "Parsing JSON with filter: $filter"
jq "$filter" "$json_file"