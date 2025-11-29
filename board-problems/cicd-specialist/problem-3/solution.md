# Solution – Advanced Pipeline with Gates

## Approach
- Multi-stage pipeline with quality gates, approvals, and rollback.

## Steps
- Stages: build → scan → test → deploy; enforce coverage/security/perf thresholds.
- Require manual approval for prod; add rollout/rollback jobs; notify on status.
- Keep infra as code; parameterize envs; guard secrets via OIDC.

## Validation
- Stage gating works; approval required for prod; rollback tested; pipeline fails appropriately on gate breach.
