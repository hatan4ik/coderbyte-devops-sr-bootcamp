#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <url>" >&2
  exit 1
fi

url="$1"
status=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
echo "status=${status}"
if [[ "$status" == "200" ]]; then
  exit 0
else
  exit 1
fi
