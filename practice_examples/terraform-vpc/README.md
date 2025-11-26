# Terraform: VPC with Public/Private Subnets + NAT

Minimal VPC setup with public/private subnets, IGW, NAT gateway, and basic web SG.

## Usage
```bash
cd practice_examples/terraform-vpc
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan
```

Adjust CIDRs/regions in `variables` section as needed. Security group here is wide-open HTTP/HTTPS for simplicity—tighten for production.
