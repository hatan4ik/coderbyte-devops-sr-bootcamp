# Kubernetes Canary Rollout Example

Two Deployments (stable + canary) behind a single Service. Canary gets a percentage of traffic via weighted selectors. Includes default-deny NetworkPolicy and Kustomize entrypoint.

## Files
- `deployment-stable.yaml` — Stable version (v1) replicas=2.
- `deployment-canary.yaml` — Canary version (v2) replicas=1, with canary label and reduced weight.
- `service.yaml` — Selects both stable and canary via shared labels; use canary label for weight.
- `networkpolicy.yaml` — Default deny; allows ingress from ingress-nginx namespace.
- `kustomization.yaml` — Build/apply entrypoint.

## Usage
```bash
kustomize build . | kubeconform -strict -ignore-missing-schemas
# Deploy
tkubectl apply -k .
```

Adjust labels/selectors and namespaces to match your ingress/controller conventions. Traffic weighting is approximated by replica counts; for precise weighting use a service mesh or ingress with canary weights.
