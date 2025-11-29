# Solution – Multi-Account Guardrails

## Approach
- Design OU/SCP guardrails with centralized logging/security and cross-account IAM.

## Steps
- Define OU layout; craft SCPs (root deny, regions, tags, encryption, deny public S3, protect audit services).
- Centralize CloudTrail/Config/GuardDuty to log/audit accounts; enable AWS Security services org-wide.
- Create cross-account roles for shared services/audit; provide Terraform/SCP JSON examples.

## Validation
- SCPs block forbidden actions; CloudTrail/Config events land in log account; cross-account role assumption verified; lint IaC.
