# Kyverno Supply Chain Policy

Kyverno ClusterPolicy to require images from trusted registries or with cosign signatures.

## Files
- `require-signed-images.yaml` — Kyverno ClusterPolicy checking image registry prefix and optional cosign annotation.

## Usage
```bash
kubectl apply -f require-signed-images.yaml
# Test with an unsigned image to see the deny
```

Adjust `spec.rules.verifyImages` to match your registries and verification config.
