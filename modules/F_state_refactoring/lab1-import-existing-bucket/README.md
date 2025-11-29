# Lab 1 – Import an Existing S3 Bucket

Attach Terraform state to a pre-created S3 bucket and harden it without recreation.

## Scenario
- The bucket already exists (created via console/CLI/CloudFormation).
- You need Terraform to manage it, add encryption, public access blocks, and versioning.
- Backend is S3+DynamoDB (`backend.hcl`). Use a **demo** bucket/prefix, not production.

## Steps
1. **Configure backend + variables**
   ```bash
   cd modules/F_state_refactoring/lab1-import-existing-bucket
   terraform init -backend-config=backend.hcl
   cp terraform.tfvars.example terraform.tfvars  # set bucket_name/owner/region
   ```

2. **Inspect drift before importing**
   ```bash
   terraform plan -refresh-only
   # Expect Terraform to propose creating the bucket because it's not in state yet.
   ```

3. **Import existing resources**
   ```bash
   # Required: import the bucket itself
   terraform import aws_s3_bucket.artifact_store <existing-bucket-name>

   # Optional: import settings already present on the bucket
   terraform import aws_s3_bucket_public_access_block.artifact_store <existing-bucket-name>
   terraform import aws_s3_bucket_versioning.artifact_store <existing-bucket-name>  # if versioning already enabled
   ```

4. **Reconcile configuration**
   ```bash
   terraform plan    # should now show only config deltas (e.g., enabling encryption/versioning)
   terraform apply   # applies hardening changes to the imported bucket
   ```

5. **Validate**
   ```bash
   terraform plan -refresh-only  # expect no changes
   terraform state list          # verify imported addresses
   ```

## What to Observe
- Import brings the bucket under state management without recreation.
- Public access blocks/versioning/encryption can be layered on safely after import.
- `plan -refresh-only` is your friend for drift checks before/after import.
