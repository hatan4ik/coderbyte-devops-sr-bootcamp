# K8s Resource Controls: ResourceQuota + LimitRange

Example manifests to enforce namespace-level quotas and per-container defaults/limits.

## Files
- `resourcequota.yaml` — Caps CPU/memory, object counts.
- `limitrange.yaml` — Default/request/limit for CPU and memory.
- `kustomization.yaml` — Apply entrypoint.

## Usage
```bash
kustomize build . | kubeconform -strict -ignore-missing-schemas
kubectl apply -k .
```

Adjust quotas/limits to your environment.
