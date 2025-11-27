# AWS Security Lab 03: VPC Network Security

Build a VPC with public/private subnets, IGW/NAT, and restrictive security groups. Add S3/Dynamo endpoints to keep private subnets off the internet.

## Purpose
- Practice VPC segmentation and least-privilege SGs.
- Use VPC endpoints to avoid public egress for common services.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).

## Usage
```bash
cd practice_examples/aws-security/03-vpc-network-security
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan
```

## What it creates
- VPC with 1 public + 1 private subnet (different AZs).
- IGW, NAT gateway for private egress.
- Security group `web_sg` allowing HTTP/HTTPS from anywhere; `app_sg` allowing only from `web_sg` and local VPC cidr.
- S3 and DynamoDB VPC endpoints.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: check plan for SG rules (no 0.0.0.0/0 on app_sg), endpoints present, NAT only for private subnet.

## Cleanup
```bash
terraform destroy
```
