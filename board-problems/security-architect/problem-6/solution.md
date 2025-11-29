# Solution – Pod Security Standards Enforcement

## Approach
- Enforce restricted pod security via PSA labels or admission policies (OPA/Kyverno).

## Steps
- Label namespaces for PSA `restricted` (or equivalent admission rules).
- Require runAsNonRoot, seccomp=RuntimeDefault, drop ALL caps, no host namespaces, readOnlyRootFilesystem; restrict hostPath/privileged.
- Define exception process with explicit labels/annotations and reviews.

## Validation
- Noncompliant pod denied; compliant pod admitted.
- `kubectl apply --dry-run`/`kubeconform` passes; `conftest`/`kyverno apply --audit` clean.
