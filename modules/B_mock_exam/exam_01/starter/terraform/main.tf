terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # A. Principal Architect: Add a remote backend for state management
  backend "s3" {
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
  default = {
    ManagedBy   = "Terraform"
    Project     = "CoderbyteExam"
    Environment = "dev"
  }
}

# A. Principal Architect & E. Cloud Architect: Use a random suffix for globally unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "${var.bucket_base_name}-${var.environment}-${random_id.bucket_suffix.hex}"

  # E. Cloud Architect: Apply tags for cost allocation and organization
  tags = var.tags
}

# D. SRE Specialist: Enable versioning for reliability and data recovery
resource "aws_s3_bucket_versioning" "example_bucket" {
  bucket = aws_s3_bucket.example_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# H. Security/DevSecOps Expert: Enforce server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example_bucket" {
  bucket = aws_s3_bucket.example_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# H. Security/DevSecOps Expert: Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "example_bucket" {
  bucket                  = aws_s3_bucket.example_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
