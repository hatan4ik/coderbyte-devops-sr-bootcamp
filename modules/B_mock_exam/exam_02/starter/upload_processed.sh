#!/bin/bash
set -euo pipefail

BUCKET_NAME="${BUCKET_NAME:-log-pipeline-processed-dev}"
INPUT_FILE="${1:-processed_logs.json}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
S3_KEY="processed/${TIMESTAMP}_$(basename "$INPUT_FILE")"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

echo "Uploading $INPUT_FILE to s3://${BUCKET_NAME}/${S3_KEY}"

aws s3 cp "$INPUT_FILE" "s3://${BUCKET_NAME}/${S3_KEY}" \
    --server-side-encryption AES256 \
    --metadata "uploaded=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "Upload complete: s3://${BUCKET_NAME}/${S3_KEY}"
