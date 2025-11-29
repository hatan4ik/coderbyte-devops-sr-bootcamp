# Challenge: Terraform Bucket

Write a small Terraform configuration in `main.tf` that:

- Uses the AWS provider.
- Takes variables:
  - `bucket_name`
  - `environment`
- Creates an S3 bucket named `<bucket_name>-<environment>`.
- Enables versioning.

No need for backend configuration.
