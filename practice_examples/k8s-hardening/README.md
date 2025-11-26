# Kubernetes Hardening Example

Hardened Deployment with probes, resource limits, security contexts, PDB, HPA, and default-deny NetworkPolicy with explicit allows.

## Files
- `deployment.yaml` — probes, limits, non-root, read-only FS, seccomp.
- `service.yaml` — ClusterIP service.
- `networkpolicy.yaml` — default deny; allows ingress from ingress-nginx and monitoring namespace.
- `pdb.yaml` — minAvailable 1.
- `hpa.yaml` — scales 2-5 based on CPU.
- `kustomization.yaml` — entrypoint for apply/validation.

## Usage
```bash
kustomize build . | kubeconform -strict -ignore-missing-schemas
# Deploy
tkubectl apply -k .
```

Adjust namespaces/labels to match your cluster (ingress controller and monitoring selectors).
