# Terraform: Two VPCs with Peering

Creates VPC A and VPC B with public subnets, route tables, and a peering connection with bidirectional routes.

## Usage
```bash
cd practice_examples/terraform-vpc-peering
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan
```

Adjust CIDRs/regions as needed. This is a learning scaffold: tighten security groups and add private subnets/NAT for production.
