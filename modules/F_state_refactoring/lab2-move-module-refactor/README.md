# Lab 2 – Refactor with `terraform state mv`

Move resources from a flat layout into a module without recreating them.

## Scenario
- You created resources in a root module (`v1-root/`).
- You want to refactor to a reusable module (`v2-module/`) while keeping the same state.
- Backend is shared via `backend.hcl` in this directory. Use demo buckets/prefixes only.

## Steps
1. **Create baseline state (v1-root)**
   ```bash
   cd modules/F_state_refactoring/lab2-move-module-refactor/v1-root
   terraform init -backend-config=../backend.hcl
   terraform apply -auto-approve   # creates bucket + log group under root addresses
   terraform state list            # aws_s3_bucket.app_state, aws_cloudwatch_log_group.app
   ```

2. **Switch to module-based config (v2-module)**
   ```bash
   cd ../v2-module
   terraform init -backend-config=../backend.hcl  # reuses the same state file
   terraform state list                           # still shows root addresses (from v1)
   ```

3. **Move state addresses to match the module layout**
   ```bash
   terraform state mv aws_s3_bucket.app_state module.storage.aws_s3_bucket.app_state
   terraform state mv aws_s3_bucket_versioning.app_state module.storage.aws_s3_bucket_versioning.app_state
   terraform state mv aws_s3_bucket_server_side_encryption_configuration.app_state module.storage.aws_s3_bucket_server_side_encryption_configuration.app_state
   terraform state mv aws_s3_bucket_public_access_block.app_state module.storage.aws_s3_bucket_public_access_block.app_state
   terraform state mv aws_cloudwatch_log_group.app module.storage.aws_cloudwatch_log_group.app
   ```

4. **Validate**
   ```bash
   terraform plan           # expect no changes after the moves
   terraform state list     # addresses should now live under module.storage.*
   terraform plan -refresh-only
   ```

## What to Observe
- `state mv` rewrites addresses without touching real infrastructure.
- After the move, configuration and state align, so `plan` is clean.
- This pattern is safe for refactors when paired with state backups and `plan -refresh-only`.
