# Solution – Harden Kubernetes Deployment

## Approach
- Apply Kubernetes hardening and reliability defaults to the deployment manifest.

## Steps
- Set runAsNonRoot, drop ALL caps, seccomp=RuntimeDefault, readOnlyRootFilesystem.
- Add liveness/readiness probes; set resource requests/limits; pin image tag.
- Apply NetworkPolicy for least-privilege ingress/egress; ensure serviceAccount with least privilege.

## Validation
- `kubeconform`/`kubectl apply --dry-run` clean; `kubectl exec` shows non-root.
- Probes pass; network tests show only intended flows allowed.
