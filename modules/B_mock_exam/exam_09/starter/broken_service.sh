#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH=${CONFIG_PATH:-/etc/item-tracker/config.json}
LOG_FILE=${LOG_FILE:-/var/log/item-tracker.log}

main() {
  echo "[INFO] starting item-tracker with config ${CONFIG_PATH}" | tee -a "${LOG_FILE}"

  # BUG: exits immediately when config is missing; no fallback or defaults.
  if [[ ! -f "${CONFIG_PATH}" ]]; then
    echo "[ERROR] config missing at ${CONFIG_PATH}" | tee -a "${LOG_FILE}" >&2
    exit 1
  fi

  while true; do
    echo "[INFO] processing tick" | tee -a "${LOG_FILE}"
    sleep 5
  done
}

main "$@"
