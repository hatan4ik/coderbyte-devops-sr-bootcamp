# Secrets Rotation – Solution Notes

## Approach
- Use AWS Secrets Manager with a rotation Lambda for a database credential. Apps fetch secrets at runtime.

## Steps
1. Create a Secrets Manager secret for the DB user.
2. Deploy rotation Lambda with handlers: create/set/test/finish.
3. Attach an IAM role allowing secret rotation + DB auth.
4. Set rotation schedule (e.g., 30 days) and test manually.
5. Ensure app loads secret at runtime (not baked); add retry/backoff.
6. Enable CloudTrail/CloudWatch logging for audit.

## Validation
- Trigger rotation manually; verify app reconnects with new creds.
- Check rotation history and Lambda logs for success.
- Confirm secret access is limited to the app role.
