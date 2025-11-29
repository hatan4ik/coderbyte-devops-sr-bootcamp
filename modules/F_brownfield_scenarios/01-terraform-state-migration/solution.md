# Solution: Terraform State Migration

## Step 1: Write Terraform Configuration

```hcl
resource "aws_s3_bucket" "legacy" {
  bucket = "legacy-app-data-prod"
}

resource "aws_iam_role" "legacy" {
  name = "legacy-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_cloudwatch_log_group" "legacy" {
  name = "/aws/legacy-app"
}
```

## Step 2: Import Resources

```bash
terraform import aws_s3_bucket.legacy legacy-app-data-prod
terraform import aws_iam_role.legacy legacy-app-role
terraform import aws_cloudwatch_log_group.legacy /aws/legacy-app
```

## Step 3: Verify No Changes

```bash
terraform plan  # Should show: No changes
```

## Step 4: Add Encryption (State Surgery)

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "legacy" {
  bucket = aws_s3_bucket.legacy.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

```bash
terraform apply
```

## Key Learnings

- Always match exact resource attributes before import
- Use `terraform state show` to inspect imported state
- Add new features incrementally after import
- Test with `terraform plan` before applying
