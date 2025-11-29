# Problem 6 – Pod Security Standards Enforcement

**Objective**: Enforce Kubernetes Pod Security Standards (restricted) across namespaces.

## Requirements
- Apply restricted profile via PSA/PSP replacement or admission policy.
- Validate seccomp, non-root, capability drops, host namespace restrictions.
- Provide a deny-by-default admission rule plus exceptions where justified.
- Document how to test compliance (kubectl, conftest, kubeconform).

## Deliverables
- Policy manifests (PSA labels/OPA/Kyverno).
- README with validation steps and exception process.
