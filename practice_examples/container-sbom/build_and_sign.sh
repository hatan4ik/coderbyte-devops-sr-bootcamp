#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-local/sbom-demo:dev}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$ROOT_DIR"

echo "[INFO] Building ${IMAGE}"
docker build -t "$IMAGE" .

if command -v syft >/dev/null 2>&1; then
  echo "[INFO] Generating SBOM (sbom.json)"
  syft "$IMAGE" -o json > sbom.json
else
  echo "[WARN] syft not installed; skipping SBOM" >&2
fi

if command -v cosign >/dev/null 2>&1; then
  echo "[INFO] Attempting to sign image with cosign"
  if [[ -n "${COSIGN_KEY:-}" ]]; then
    cosign sign --key "$COSIGN_KEY" "$IMAGE"
  else
    echo "[INFO] No COSIGN_KEY set; attempting keyless if configured"
    cosign sign "$IMAGE" || echo "[WARN] cosign sign failed (no keyless setup?)" >&2
  fi
else
  echo "[WARN] cosign not installed; skipping signing" >&2
fi

echo "[INFO] Done"
