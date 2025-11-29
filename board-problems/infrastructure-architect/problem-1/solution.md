# Solution – Secure S3 Baseline

## Approach
- Harden an existing S3 bucket via IaC to meet production controls.

## Steps
- Enable Block Public Access; default encryption (SSE-S3 or KMS); versioning; server access logging.
- Enforce TLS-only via bucket policy; add lifecycle if required; tag resources.
- Create least-privilege IAM policy for app role to access bucket.

## Validation
- `terraform plan/apply`; `aws s3api get-bucket-policy` shows TLS/encryption; public access attempts fail.
- `tfsec`/`tflint` clean; sample app can access via IAM role.*** End Patch Error: The JSON object is not properly formatted; it should contain "command" and optionally "workdir", "timeout_ms", and "with_sudo".
