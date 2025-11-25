#!/bin/bash
# Log Rotation - Rotate log files when they exceed size limit

if [ $# -eq 0 ]; then
    echo "Usage: $0 <log_file> [max_size_mb]"
    exit 1
fi

log_file="$1"
max_size_mb="${2:-10}"
max_size_bytes=$((max_size_mb * 1024 * 1024))

if [ ! -f "$log_file" ]; then
    echo "Error: Log file '$log_file' not found"
    exit 1
fi

file_size=$(stat -c%s "$log_file" 2>/dev/null || stat -f%z "$log_file" 2>/dev/null)

if [ "$file_size" -gt "$max_size_bytes" ]; then
    timestamp=$(date +"%Y%m%d_%H%M%S")
    rotated_file="${log_file}.${timestamp}"
    
    mv "$log_file" "$rotated_file"
    touch "$log_file"
    
    echo "Log rotated: $log_file -> $rotated_file"
    
    # Keep only last 5 rotated files
    ls -t "${log_file}".* 2>/dev/null | tail -n +6 | xargs rm -f
else
    echo "Log file size ($(($file_size / 1024 / 1024))MB) is below threshold (${max_size_mb}MB)"
fi