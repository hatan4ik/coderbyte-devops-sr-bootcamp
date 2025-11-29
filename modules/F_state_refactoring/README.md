# Module F – Terraform State Refactoring (Brownfield Skills, Canonical)

Practice importing existing resources and reshaping state addresses without rebuilding infrastructure.

## Labs
- **Lab 1 – Import existing S3 bucket** (`lab1-import-existing-bucket/`): Attach Terraform state to a pre-created AWS S3 bucket and harden it without recreation.
- **Lab 2 – Refactor with `terraform state mv`** (`lab2-move-module-refactor/`): Move resources from a flat layout into a module while preserving state.

## Why This Exists
- Addresses real-world brownfield work called out in the editorial review.
- Demonstrates safe workflows for imports, refactors, and drift detection.
- Uses AWS-only examples to align with the repository’s primary cloud.

## How to Use
1. Provide AWS credentials (`AWS_PROFILE`/`AWS_REGION`) and adjust `backend.hcl` paths per lab.
2. Run each lab’s README step-by-step. Commands are written to avoid accidental recreation.
3. After finishing, run `terraform plan` to ensure the state is aligned and no changes are pending.

## Safety Tips
- Use dedicated demo buckets/prefixes for these labs; do **not** point at production backends.
- Export/backup your state before running `terraform state mv` on anything real.
- Prefer `terraform plan -refresh-only` after imports/moves to validate alignment.
