#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <log_file> [top_n]" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

log_file="$1"
limit="${2:-5}"

if [[ ! -f "$log_file" ]]; then
  echo "Error: file not found: $log_file" >&2
  exit 1
fi

if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
  echo "Error: top_n must be a positive integer" >&2
  exit 1
fi

# Extract first field (IP), count, sort desc, take N
awk '{print $1}' "$log_file" \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n "$limit"
