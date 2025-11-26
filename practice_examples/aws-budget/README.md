# Terraform: AWS Budget Alert

Creates a simple AWS budget with email notification for monthly cost threshold.

## Usage
```bash
cd practice_examples/aws-budget
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'email=you@example.com'
```

Set `email` to your alert recipient. This is a minimal example; adjust amount/period/notification as needed.
