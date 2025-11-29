# Problem 7 – Secrets Rotation and Storage

**Objective**: Design and implement automated secrets rotation.

## Requirements
- Use a managed secrets service (e.g., Secrets Manager) with rotation Lambda.
- Rotate at least one database credential with grace period for cutover.
- Ensure apps pull secrets at runtime (no baked secrets).
- Audit logging enabled for secret access.

## Deliverables
- Rotation Lambda/code or config.
- README/runbook describing rotation schedule and rollback.
