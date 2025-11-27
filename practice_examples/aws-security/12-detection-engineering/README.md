# AWS Security Lab 12: Detection Engineering (EventBridge + SNS)

Create EventBridge rules to catch root logins and IAM changes, sending notifications to an SNS topic. Uses minimal Terraform, no email subscription by default.

## Purpose
- Detect high-signal events: root ConsoleLogin, IAM policy/role changes.
- Deliver to SNS (subscribe email/SQS/Lambda later).

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- Optional: add SNS subscriptions manually after apply.

## Usage
```bash
cd practice_examples/aws-security/12-detection-engineering
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan
```

## What it creates
- SNS topic `security-alerts` (no subs by default).
- EventBridge rules:
  - Root console login events (ConsoleLogin + user=root).
  - IAM changes (Create/Update/Delete Role/Policy/User/AccessKey).
- Targets: SNS topic.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: inspect plan for EventBridge patterns; after apply, test by simulating events or checking rules in console.

## Cleanup
```bash
terraform destroy
```
