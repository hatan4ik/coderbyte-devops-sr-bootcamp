# AWS Security Lab 01: IAM Basics

Create IAM users, groups, and policies with least privilege and MFA enforcement.

## Purpose
- Practice IAM building blocks (user/group/policy).
- Enforce MFA for console access.
- Apply least privilege to a demo S3 bucket.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (uses local state).

## Usage
```bash
cd practice_examples/aws-security/01-iam-basics
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'allowed_bucket=my-secure-bucket'
```

## What it creates
- Group `developers` with inline policy allowing list/get/put on the specified bucket.
- IAM user `devuser` in group `developers`.
- Account password policy with strong settings.
- IAM policy requiring MFA for console and `aws:MultiFactorAuthPresent` on sensitive actions.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Policy sanity: Inspect plan to verify MFA condition and limited S3 actions. No automated apply in shared env.

## Cleanup
```bash
terraform destroy
```
