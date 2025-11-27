# AWS Security Lab 07: CI/CD Supply Chain Safeguards

Create a CodeBuild project with encrypted artifacts/logs, VPC isolation (optional), and a buildspec that runs Trivy/semgrep. No plaintext secrets.

## Purpose
- Demonstrate secure defaults for CodeBuild: KMS, env var hygiene, logging.
- Run basic SCA/SAST (Trivy fs, semgrep) in a buildspec.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- Adjust VPC/Subnet/Security Group IDs if you want VPC isolation (optional inputs).

## Usage
```bash
cd practice_examples/aws-security/07-cicd-supply-chain
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'project_name=secure-build' -var 'artifact_bucket=your-artifact-bucket'
```

## What it creates
- KMS key for CodeBuild artifacts/logs.
- S3 artifact bucket (if provided) or NO_ARTIFACTS config.
- CodeBuild project using a hardened Linux image, environment variables with no plaintext secrets, buildspec invoking Trivy/semgrep.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: inspect plan for KMS use, no privileged mode, and buildspec commands.

## Cleanup
```bash
terraform destroy
```
