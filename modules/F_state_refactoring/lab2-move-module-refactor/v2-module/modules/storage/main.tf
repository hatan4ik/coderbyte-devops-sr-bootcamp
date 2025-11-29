locals {
  tags = {
    ManagedBy   = "terraform"
    Environment = var.environment
    Service     = var.service_name
    Owner       = var.owner
  }
}

resource "aws_s3_bucket" "app_state" {
  bucket        = "${var.service_name}-${var.environment}-state-demo"
  force_destroy = false
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "app_state" {
  bucket = aws_s3_bucket.app_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_state" {
  bucket = aws_s3_bucket.app_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_state" {
  bucket = aws_s3_bucket.app_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/${var.service_name}/${var.environment}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

output "bucket_name" {
  value       = aws_s3_bucket.app_state.id
  description = "State bucket name"
}

output "log_group" {
  value       = aws_cloudwatch_log_group.app.name
  description = "Log group name"
}
