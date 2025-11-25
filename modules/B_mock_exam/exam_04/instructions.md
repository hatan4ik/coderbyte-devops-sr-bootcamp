# Mock Exam #4 – Infrastructure as Code (IaC) Security

## Scenario
You have inherited a Terraform stack with several security issues. Harden the configuration and document the controls you add.

## Requirements
1. **S3 Bucket hardening**
   - Ensure private access (no public ACLs/policies).
   - Enable default encryption and versioning.
   - Add server-side logging or a lifecycle rule for old versions.
2. **Security Groups**
   - Remove wide-open ingress (`0.0.0.0/0`) except where justified.
   - Restrict SSH to a provided CIDR variable.
3. **IAM**
   - Avoid wildcard permissions; scope policies to least privilege.
   - Add tags to all IAM resources and document purpose.
4. **Static analysis**
   - Add a `terraform-plan.yml` or similar pipeline config to run `terraform fmt`, `validate`, and `tfsec`.
5. **Documentation**
   - In `starter/README.md`, explain what you hardened and any residual risks.

### Deliverables
- Updated Terraform in `starter/terraform` with secure defaults.
- CI/static-analysis config.
- README capturing security decisions.
