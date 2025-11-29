#!/usr/bin/env bash
set -euo pipefail

EXAM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "===================================="
echo " Mock Exam #7 – SRE & Observability"
echo "===================================="
echo
echo "Instructions:"
echo "  ${EXAM_DIR}/instructions.md"
echo
echo "Suggested timebox: 60–90 minutes."
echo "Work in:"
echo "  ${EXAM_DIR}/starter"
echo

read -rp "Press ENTER to show instructions and start the timer..."

clear
cat "${EXAM_DIR}/instructions.md"
echo
echo "Timer started. (Soft timer, not enforced.)"

START_TS=$(date +%s)
while true; do
  sleep 60
  now=$(date +%s)
  elapsed=$(((now - START_TS) / 60))
  echo "[INFO] Elapsed: ${elapsed} minutes"
done
