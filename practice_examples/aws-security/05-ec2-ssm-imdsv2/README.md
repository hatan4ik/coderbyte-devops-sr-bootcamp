# AWS Security Lab 05: EC2 Hardening (IMDSv2 + SSM)

Launch an EC2 instance profile and (optionally) a launch template enforcing IMDSv2 and Session Manager (no SSH).

## Purpose
- Enforce IMDSv2.
- Use SSM Session Manager instead of SSH.
- Restrict instance profile permissions.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- AMI lookup here uses Amazon Linux 2 via data source; adjust region/owners as needed.

## Usage
```bash
cd practice_examples/aws-security/05-ec2-ssm-imdsv2
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan
```

## What it creates
- IAM role + instance profile with SSM core policy only.
- Security group allowing only HTTPS egress (no ingress).
- Launch template enforcing IMDSv2 and associating instance profile.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: plan shows `http_tokens = required`, no SSH ingress, and minimal IAM policy.

## Cleanup
```bash
terraform destroy
```

## Diagram
```mermaid
graph TD
  LT[Launch Template] --> IMDS[IMDSv2 required]
  LT --> IP[Instance Profile (SSM only)]
  LT --> SG[SG: HTTPS egress only]
  EC2[EC2 Instance] -->|launches with| LT
  EC2 --> SSM[SSM Session Manager]
```
