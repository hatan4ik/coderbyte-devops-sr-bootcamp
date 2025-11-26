terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment, e.g. dev/stage/prod"
  default     = "dev"
}

variable "bucket_base_name" {
  type        = string
  description = "Base name for the S3 bucket"
  default     = "app-data"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

locals {
  env         = lower(var.environment)
  bucket_name = "${var.bucket_base_name}-${local.env}"
  tags = merge(
    {
      ManagedBy   = "Terraform"
      Project     = "CoderbyteExam01"
      Environment = local.env
    },
    var.tags
  )
}

# S3 bucket with sane defaults
resource "aws_s3_bucket" "app" {
  bucket        = local.bucket_name
  force_destroy = false

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# SRE: Enable access logging for security audits and operational troubleshooting.
resource "aws_s3_bucket_logging" "app" {
  bucket = aws_s3_bucket.app.id

  # In a real project, this would be a separate, dedicated logging bucket.
  # For this exam, we log to the bucket itself under a 'logs/' prefix.
  target_bucket = aws_s3_bucket.app.id
  target_prefix = "logs/"
}

output "bucket_id" {
  value       = aws_s3_bucket.app.id
  description = "The ID (name) of the provisioned S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.app.arn
  description = "The ARN of the provisioned S3 bucket."
}
