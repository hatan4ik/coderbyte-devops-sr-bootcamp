# Solution – Secrets Rotation

## Approach
- Automate secrets rotation with managed store + rotation Lambda and runtime secret retrieval.

## Steps
- Store secret in Secrets Manager; implement rotation Lambda (create/set/test/finish) for DB cred.
- Set rotation schedule; ensure app loads secret at runtime (not baked).
- Enable CloudTrail logging for secret access; document rollback path.

## Validation
- Manual rotation succeeds; app reconnects with new secret.
- Rotation history/logs clean; access limited to intended role.
