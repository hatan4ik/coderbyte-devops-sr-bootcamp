#!/bin/bash
# File Organizer - Sort files by extension into directories

if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

target_dir="$1"
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' not found"
    exit 1
fi

cd "$target_dir" || exit 1

for file in *; do
    if [ -f "$file" ]; then
        ext="${file##*.}"
        if [ "$ext" != "$file" ]; then
            mkdir -p "$ext"
            mv "$file" "$ext/"
            echo "Moved $file to $ext/"
        else
            mkdir -p "no_extension"
            mv "$file" "no_extension/"
            echo "Moved $file to no_extension/"
        fi
    fi
done