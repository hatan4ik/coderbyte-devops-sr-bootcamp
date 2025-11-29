# Solution – Multi-Region Terraform Module

## Approach
- Build reusable Terraform modules for VPC/EKS/RDS with optional cross-region DR.

## Steps
- Define modules with clear inputs/outputs; per-env/workspace variables.
- VPC: multi-AZ subnets, gateways, security groups; EKS/RDS: multi-AZ, backups, parameter groups.
- Optional cross-region replication/DR settings; include health checks/runbooks.
- Validate with `fmt/validate/tflint/tfsec`; document usage.

## Validation
- `terraform plan` per env; apply in non-prod; DR/failover drill documented.
