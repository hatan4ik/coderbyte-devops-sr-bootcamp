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
  description = "Environment (dev/stage/prod)"
  default     = "dev"
}

variable "bucket_name" {
  type        = string
  description = "Base name for the log bucket"
  default     = "coderbyte-log-pipeline"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

locals {
  env         = lower(var.environment)
  bucket_name = "${var.bucket_name}-${local.env}"
  tags = merge(
    {
      ManagedBy   = "Terraform"
      Environment = local.env
      Project     = "log-pipeline"
    },
    var.tags
  )
}

resource "aws_s3_bucket" "logs" {
  bucket        = local.bucket_name
  force_destroy = false

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_name" {
  value       = aws_s3_bucket.logs.bucket
  description = "Provisioned bucket name."
}
