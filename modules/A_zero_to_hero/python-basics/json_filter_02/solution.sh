#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <source_directory> <destination_directory>" >&2
  exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="$2"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Error: Source directory '$SOURCE_DIR' not found." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST_DIR}/${ARCHIVE_NAME}"

# Use -C to change to the source directory's parent to avoid including the full path in the archive
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

echo "Backup created successfully: ${ARCHIVE_PATH}"
exit 0
