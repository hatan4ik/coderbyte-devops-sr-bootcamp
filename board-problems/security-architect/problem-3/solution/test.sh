#!/bin/bash
set -e

echo "=== Testing Pod Security Standards ==="

echo "1. Creating namespace with PSS..."
kubectl apply -f namespace.yaml

echo "2. Testing compliant deployment (should succeed)..."
kubectl apply -f deployment-compliant.yaml
kubectl wait --for=condition=available --timeout=60s deployment/secure-app -n secure-apps
echo "✓ Compliant deployment succeeded"

echo "3. Testing non-compliant deployment (should fail)..."
if kubectl apply -f deployment-blocked.yaml 2>&1 | grep -q "violates PodSecurity"; then
    echo "✓ Non-compliant deployment blocked as expected"
else
    echo "✗ Non-compliant deployment was not blocked!"
    exit 1
fi

echo "4. Verifying pod security..."
kubectl get pods -n secure-apps -o jsonpath='{.items[0].spec.securityContext}' | jq .

echo "=== All tests passed ==="
