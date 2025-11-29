# Problem 4 – Blue/Green Deployment Pipeline

**Objective**: Implement a blue/green deployment pipeline with automated health checks and rollback.

## Requirements
- Separate blue/green environments with traffic switch step.
- Health checks before and after cutover; rollback on failure.
- Notifications on success/failure.
- Promotion requires passing quality gates (tests + scans).

## Deliverables
- Pipeline definition with blue/green stages.
- Documentation on how to trigger cutover/rollback.
