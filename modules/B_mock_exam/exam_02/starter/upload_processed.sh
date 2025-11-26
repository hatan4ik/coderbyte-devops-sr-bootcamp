#!/usr/bin/env bash
set -euo pipefail

: "${BUCKET:?BUCKET environment variable is required}"
INPUT_JSON="${1:-processed.json}"
KEY="${KEY:-processed/$(date +%Y%m%d-%H%M%S).json}"

if [[ ! -f "${INPUT_JSON}" ]]; then
  echo "Input file not found: ${INPUT_JSON}" >&2
  exit 1
fi

echo "Uploading ${INPUT_JSON} to s3://${BUCKET}/${KEY}"
aws s3 cp "${INPUT_JSON}" "s3://${BUCKET}/${KEY}"
echo "Done."
