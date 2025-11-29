# AWS Security Lab 14: Secrets Manager with Rotation

Create a Secrets Manager secret with automatic rotation via a Lambda function. Demonstrates KMS encryption, rotation schedule, and a minimal rotation Lambda.

## Purpose
- Show secure secret storage with rotation enabled.
- Use a Lambda rotation function (placeholder logic) with least privilege.

## Prereqs
- Terraform, AWS credentials (sandbox), backend disabled (local state).
- Rotation Lambda here is a stub; integrate with a real backend in production.

## Usage
```bash
cd practice_examples/aws-security/14-secrets-rotation
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'secret_name=demo/rotated-secret'
```

## What it creates
- KMS-encrypted secret in Secrets Manager.
- Rotation schedule (30 days) with Lambda function and execution role.
- IAM role with minimal permissions to get/put secret value.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: after apply, verify rotation is enabled and Lambda has minimal permissions.

## Cleanup
```bash
terraform destroy
```

## Diagram
```mermaid
graph TD
  Sec[Secrets Manager secret] --> Rot[Rotation schedule]
  Rot --> L[Lambda rotation fn]
  L -->|IAM| RRole[Rotation role (least priv)]
```
