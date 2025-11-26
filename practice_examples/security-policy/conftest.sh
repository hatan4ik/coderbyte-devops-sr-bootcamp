#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if ! command -v conftest >/dev/null 2>&1; then
  echo "[ERROR] conftest not installed" >&2
  exit 1
fi

echo "[INFO] Testing Kubernetes policy"
conftest test samples/deployment.yaml -p policy

echo "[INFO] Testing Terraform plan policy"
conftest test samples/plan.json -p policy
