# AWS Security Lab 09: Cross-Account IAM Role (Hub/Spoke)

Create a role in Account A trusted by Account B, with least-privilege access to a specific S3 bucket. Useful for hub/spoke patterns.

## Purpose
- Practice cross-account trust policies and scoped permissions.
- Use external IDs to reduce confused deputy risk.

## Prereqs
- Terraform, AWS credentials (for Account A) with IAM rights; backend disabled (local state).
- Set `trusted_account_id`, `external_id`, and `target_bucket` variables.

## Usage
```bash
cd practice_examples/aws-security/09-cross-account-iam
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'trusted_account_id=123456789012' -var 'external_id=your-external-id' -var 'target_bucket=your-bucket'
```

## What it creates
- IAM role `cross-account-reader` with trust to the specified account and external ID condition.
- Inline policy allowing Get/List on the specified bucket only.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: verify trust policy has correct account and external ID; S3 policy scoped to target bucket.

## Cleanup
```bash
terraform destroy
```
