#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-}" 
if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image>" >&2
  exit 1
fi

if ! command -v cosign >/dev/null 2>&1; then
  echo "[ERROR] cosign not installed" >&2
  exit 1
fi

echo "[INFO] Verifying signature for $IMAGE"
cosign verify "$IMAGE" || {
  echo "[WARN] verification failed" >&2
  exit 1
}
