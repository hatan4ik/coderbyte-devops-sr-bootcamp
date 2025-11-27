# AWS Security Lab 11: CodePipeline with Encrypted Artifacts

Build a minimal CodePipeline that uses KMS-encrypted artifacts and a CodeBuild stage running security scans. No plaintext secrets; IAM roles are least-privilege for S3 + CodeBuild.

## Purpose
- Demonstrate secure defaults in CodePipeline/CodeBuild.
- Encrypted artifact store (S3 + KMS), logging, and scoped IAM roles.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- Adjust bucket name; uses "no source" (manual artifact upload) for simplicity.

## Usage
```bash
cd practice_examples/aws-security/11-codepipeline-supply-chain
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'artifact_bucket=your-artifacts-bucket'
```

## What it creates
- KMS key for pipeline artifacts.
- S3 artifact bucket (if provided) with SSE, versioning, public-block.
- CodeBuild project (from Lab 07 buildspec style) for scanning placeholder.
- CodePipeline with Source (S3) -> Build (CodeBuild) stages; roles scoped to S3 + CodeBuild.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: verify plan shows KMS, artifact bucket SSE/versioning/public block, IAM roles limited to S3/CodeBuild.

## Cleanup
```bash
terraform destroy
```
