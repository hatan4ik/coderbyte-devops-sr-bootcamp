# IaC Security Starter

The Terraform here is intentionally lax. Harden it by tightening IAM, locking down the S3 bucket, and restricting network access. Run the included GitHub Actions workflow locally with `act` or reuse the steps manually:

```bash
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
# run tfsec if installed
```

Document the controls you add and any trade-offs.
