# Problem 1 – Harden Kubernetes Deployment

**Objective**: Fix an insecure Kubernetes deployment manifest.

## Requirements
- Enforce non-root, drop capabilities, set seccomp profile.
- Add resource requests/limits and liveness/readiness probes.
- Apply NetworkPolicy to restrict ingress/egress.
- Provide updated manifest and brief rationale.

## Deliverables
- Fixed deployment YAML.
- Short README explaining changes and how to validate.
