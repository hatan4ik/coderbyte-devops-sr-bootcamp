#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

log="$tmpdir/access.log"
cat > "$log" <<'LOG'
10.0.0.1 - - [10/Nov/2024:10:00:00 +0000] "GET /" 200 123
10.0.0.2 - - [10/Nov/2024:10:00:01 +0000] "GET /" 200 123
10.0.0.1 - - [10/Nov/2024:10:00:02 +0000] "GET /a" 404 0
10.0.0.3 - - [10/Nov/2024:10:00:03 +0000] "GET /" 200 123
10.0.0.1 - - [10/Nov/2024:10:00:04 +0000] "GET /b" 500 0
LOG

output=$("$(dirname "$0")/top_ips.sh" "$log" 2>/dev/null)
expected=$(cat <<'EXP'
      3 10.0.0.1
      1 10.0.0.3
      1 10.0.0.2
EXP
)
if [[ "$output" != "$expected" ]]; then
  echo "Test failed" >&2
  echo "Expected:" >&2
  echo "$expected" >&2
  echo "Got:" >&2
  echo "$output" >&2
  exit 1
fi

echo "OK"
