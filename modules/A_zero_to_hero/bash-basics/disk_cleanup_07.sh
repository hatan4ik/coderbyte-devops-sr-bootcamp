#!/bin/bash
# Disk Cleanup - Find and optionally remove large files

threshold=${1:-100}  # Default 100MB
action=${2:-"list"}  # Default action is list

echo "Finding files larger than ${threshold}MB..."

find / -type f -size +${threshold}M 2>/dev/null | while read -r file; do
    size=$(du -h "$file" | cut -f1)
    if [ "$action" = "remove" ]; then
        echo "Removing: $file ($size)"
        rm -f "$file"
    else
        echo "Found: $file ($size)"
    fi
done

if [ "$action" = "list" ]; then
    echo ""
    echo "To remove these files, run: $0 $threshold remove"
fi