#!/bin/bash
# HTTP Health Check - Check if URL is accessible

if [ $# -eq 0 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

url="$1"
status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$status" -eq 200 ]; then
    echo "✓ $url is accessible (HTTP $status)"
    exit 0
else
    echo "✗ $url is not accessible (HTTP $status)"
    exit 1
fi