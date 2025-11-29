# IAM Least Privilege – Solution Notes

## What Changed
- Scoped S3 access to a single bucket + objects; enforced TLS via `aws:SecureTransport`.
- Restricted CloudWatch Logs permissions to the app log group.
- Added explicit deny for IAM console actions without MFA (defense-in-depth).

## How to Validate
1. **Policy simulator**: Confirm access only to the intended bucket/log group; IAM actions denied without MFA.
2. **Access Analyzer**: Run analyzer to detect unintended access.
3. **Functional test**: Attach to test role and verify allowed/denied actions:
   ```bash
   aws s3 ls s3://example-app-bucket    # should succeed
   aws iam list-users                   # should fail (no MFA)
   ```

## Notes
- Replace ARNs/account IDs with your environment.
- Keep IAM actions separated per role/use case; avoid wildcard `*`.
