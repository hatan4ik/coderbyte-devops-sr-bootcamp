#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-local/container-security:dev}"

echo "[INFO] Building image ${IMAGE}"
docker build -t "${IMAGE}" .

echo "[INFO] Running trivy (if installed)"
if command -v trivy >/dev/null 2>&1; then
  trivy image --severity CRITICAL,HIGH --exit-code 1 "${IMAGE}"
else
  echo "trivy not installed; skipping"
fi

echo "[INFO] Generating SBOM with syft (if installed)"
if command -v syft >/dev/null 2>&1; then
  syft "${IMAGE}" -o json > sbom.json
  echo "SBOM written to sbom.json"
else
  echo "syft not installed; skipping"
fi
