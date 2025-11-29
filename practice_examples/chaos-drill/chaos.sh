#!/usr/bin/env bash
set -euo pipefail

selector="${1:-app=observability-slo}"
interval="${2:-60}"

while true; do
  pods=$(kubectl get pods -l "$selector" -o jsonpath='{.items[*].metadata.name}')
  for p in $pods; do
    echo "[CHAOS] Deleting pod $p"
    kubectl delete pod "$p" --grace-period=0 --force || true
    sleep 5
  done
  echo "[CHAOS] Sleeping ${interval}s"
  sleep "$interval"
done
