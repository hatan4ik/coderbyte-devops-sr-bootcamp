#!/bin/bash
set -euo pipefail

IMAGE_NAME="${1:-secure-app:latest}"

echo "=== Container Security Scanning ==="
echo "Image: $IMAGE_NAME"
echo ""

# Trivy vulnerability scan
echo "1. Running Trivy vulnerability scan..."
trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE_NAME"

# Hadolint Dockerfile linting
echo ""
echo "2. Running Hadolint..."
hadolint Dockerfile

# Generate SBOM
echo ""
echo "3. Generating SBOM with Syft..."
syft "$IMAGE_NAME" -o json > sbom.json
syft "$IMAGE_NAME" -o spdx-json > sbom-spdx.json
echo "SBOM saved to sbom.json and sbom-spdx.json"

# Grype vulnerability scan from SBOM
echo ""
echo "4. Running Grype scan..."
grype sbom:sbom.json --fail-on high

# Image analysis
echo ""
echo "5. Image analysis..."
docker inspect "$IMAGE_NAME" | jq '.[0] | {
  User: .Config.User,
  ExposedPorts: .Config.ExposedPorts,
  Env: .Config.Env,
  Size: .Size
}'

echo ""
echo "=== Security scan complete ==="
