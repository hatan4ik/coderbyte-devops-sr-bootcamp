#!/usr/bin/env bash
set -e

API_URL="$1"

if [[ -z "$API_URL" ]]; then
  echo "Usage: $0 <api_invoke_url>"
  exit 1
fi

ITEM_ID="test-item-$(date +%s)"
ITEM_DATA="hello-world"

echo "--- Test Suite for Item Tracker API ---"

# 1. Test POST /items
echo "[TEST] Creating a new item with ID: ${ITEM_ID}"
response_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Content-Type: application/json" \
  -d "{\"itemID\": \"${ITEM_ID}\", \"data\": \"${ITEM_DATA}\"}" \
  "${API_URL}/items")

if [[ "$response_code" -ne 201 ]]; then
  echo "[FAIL] Expected HTTP 201 Created, but got ${response_code}"
  exit 1
fi
echo "[PASS] Item created successfully."

# 2. Test GET /items/{itemID}
echo "[TEST] Retrieving item with ID: ${ITEM_ID}"
response_body=$(curl -s -X GET "${API_URL}/items/${ITEM_ID}")
retrieved_data=$(echo "$response_body" | jq -r '.data')

if [[ "$retrieved_data" != "$ITEM_DATA" ]]; then
  echo "[FAIL] Retrieved data does not match. Expected '${ITEM_DATA}', got '${retrieved_data}'"
  exit 1
fi
echo "[PASS] Item retrieved successfully and data matches."

echo "--- All tests passed! ---"