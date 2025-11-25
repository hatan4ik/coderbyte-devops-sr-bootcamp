# Networking & Peering Starter

## Usage
```bash
cd terraform
terraform init -backend=false
terraform plan
```

After apply, test connectivity by launching two small EC2 instances (one per VPC) with the provided security groups and ping between them, or run AWS Reachability Analyzer targeting the subnet ENIs.
