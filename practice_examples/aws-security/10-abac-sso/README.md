# AWS Security Lab 10: ABAC for Federated Access

Demonstrate attribute-based access control using IAM tags. Role trust expects a `department` principal tag, and the policy allows actions only on resources with matching tags.

## Purpose
- Practice ABAC with PrincipalTag and ResourceTag conditions.
- Show how to scope access by department/team without static ARNs.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- Federated identity provider assumed to pass `department` attribute; here we mock with an IAM principal tag.

## Usage
```bash
cd practice_examples/aws-security/10-abac-sso
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'department=engineering'
```

## What it creates
- IAM role `abac-role` expecting `sts:TagSession` with `department` tag.
- Inline policy allowing S3 actions only when `aws:ResourceTag/department` matches `aws:PrincipalTag/department`.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: verify plan shows PrincipalTag/ResourceTag conditions; policy scoped by department tag.

## Cleanup
```bash
terraform destroy
```
