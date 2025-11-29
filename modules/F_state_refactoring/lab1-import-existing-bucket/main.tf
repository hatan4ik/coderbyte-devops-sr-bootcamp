terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Environment = var.environment
      Component   = "state-refactor-lab1"
      Owner       = var.owner
    }
  }
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment label for tagging"
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Owner/team tag"
  default     = "platform-team"
}

variable "bucket_name" {
  type        = string
  description = "Name of the pre-existing S3 bucket to import"
}

variable "kms_key_arn" {
  type        = string
  description = "Optional CMK ARN for encryption (falls back to AES256)"
  default     = null
}

variable "enable_versioning" {
  type        = bool
  description = "Enable bucket versioning after import"
  default     = true
}

resource "aws_s3_bucket" "artifact_store" {
  bucket        = var.bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifact_store" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.artifact_store.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_store" {
  bucket = aws_s3_bucket.artifact_store.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
    }
    bucket_key_enabled = true
  }
}

output "bucket_name" {
  value       = aws_s3_bucket.artifact_store.id
  description = "Imported bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.artifact_store.arn
  description = "Imported bucket ARN"
}
