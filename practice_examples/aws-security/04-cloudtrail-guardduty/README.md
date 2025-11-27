# AWS Security Lab 04: CloudTrail + GuardDuty

Enable organization-style logging and detection for a single account/region: CloudTrail to an encrypted, locked S3 bucket and GuardDuty detector.

## Purpose
- Configure CloudTrail with SSE-KMS and public access blocking.
- Enable GuardDuty with all data sources.

## Prereqs
- Terraform, AWS credentials (sandbox), terraform backend disabled (local state).
- KMS key is optional; using SSE-S3 for simplicity here.

## Usage
```bash
cd practice_examples/aws-security/04-cloudtrail-guardduty
terraform init -backend=false
terraform fmt -check
terraform validate
terraform plan -var 'trail_bucket=your-trail-bucket-name'
```

## What it creates
- S3 bucket for CloudTrail with versioning, SSE, and public access block.
- CloudTrail (multi-region) delivering to the bucket.
- GuardDuty detector enabled with default data sources.

## Tests
- Static: `terraform fmt -check`, `terraform validate`.
- Logic: verify plan shows SSE, versioning, public access block, and GuardDuty enabled.

## Cleanup
```bash
terraform destroy
```

## Diagram
```mermaid
graph TD
  CT[CloudTrail (multi-region)] --> SB[S3 trail bucket (SSE+versioning+block public)]
  CT --> GF[Log file validation]
  GD[GuardDuty Detector]:::detect

  classDef detect fill:#ffecec,stroke:#f00,stroke-width:1px;
```
