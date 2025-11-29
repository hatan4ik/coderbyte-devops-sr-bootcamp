# Solution – Pod Security Standards (Restricted)

## Approach
- Enforce the restricted PSS profile to block noncompliant pods and admit compliant ones.

## Steps
- Create namespace with PSS labels set to `restricted`.
- Provide compliant deployment manifest: non-root, drop capabilities, seccomp RuntimeDefault, no privilege escalation, readOnlyRootFilesystem.
- Provide non-compliant deployment manifest to demonstrate blocking.
- Add test script to apply both and show enforcement.

## Validation
- `kubectl apply --dry-run=client` passes; restricted namespace present.
- Compliant deployment schedules; non-compliant deployment is denied by admission/PSA.
