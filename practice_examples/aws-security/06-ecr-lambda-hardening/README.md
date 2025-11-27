# AWS Security Lab 06: ECR + Lambda Hardening

Create an ECR repository with scan-on-push + lifecycle, and a Lambda function with least-priv role and env encryption.

## Purpose
- Enforce ECR scan on push and retention.
- Harden Lambda with least privilege, env var encryption, and basic settings.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- A zip file is created from the inline lambda source.

## Usage
```bash
cd practice_examples/aws-security/06-ecr-lambda-hardening
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'lambda_name=secure-lambda'
```

## What it creates
- ECR repo with scan_on_push=true and a lifecycle policy expiring untagged images after 7 days.
- Lambda function (Python) with role allowing only CloudWatch Logs.
- Env var encryption using AWS-managed KMS (can swap to CMK).

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: plan shows scan_on_push, lifecycle policy, and lambda role limited to logs.

## Cleanup
```bash
terraform destroy
```

## Diagram
```mermaid
graph TD
  ECR[ECR repo
scan_on_push+retention] --> IMG[Images]
  IMG --> L[Lambda]
  L -->|role| R[IAM role (logs only)]
  L --> CW[CloudWatch Logs]
```
