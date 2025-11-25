#!/bin/bash
# Backup Script - Create timestamped backup of directory

if [ $# -eq 0 ]; then
    echo "Usage: $0 <source_directory> [backup_location]"
    exit 1
fi

source_dir="$1"
backup_location="${2:-./backups}"
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_name="backup_$(basename "$source_dir")_$timestamp.tar.gz"

if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' not found"
    exit 1
fi

mkdir -p "$backup_location"
tar -czf "$backup_location/$backup_name" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"

echo "Backup created: $backup_location/$backup_name"