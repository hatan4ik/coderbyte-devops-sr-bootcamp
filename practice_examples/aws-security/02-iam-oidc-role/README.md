# AWS Security Lab 02: IAM Role with OIDC (GitHub Actions style)

Create an IAM role with an OIDC trust for a CI provider (example uses GitHub Actions), granting minimal permissions to an S3 bucket.

## Purpose
- Practice OIDC federation and least privilege for CI.
- Trust policy restricted to specific repo/branch.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- Replace repo info in variables.

## Usage
```bash
cd practice_examples/aws-security/02-iam-oidc-role
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'repo=your-org/your-repo' -var 'bucket=your-ci-bucket'
```

## What it creates
- IAM OIDC provider for `token.actions.githubusercontent.com` (if not existing).
- IAM role `ci-oidc-role` with trust limited to the repo/branch.
- Inline policy allowing put/get/list on the specified bucket.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: inspect plan to confirm `sub` claim matches repo/branch and policy scoped to target bucket.

## Cleanup
```bash
terraform destroy
```
