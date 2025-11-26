terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Service     = var.service_name
      ManagedBy   = "Terraform"
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
  description = "Environment (dev/stage/prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}

variable "service_name" {
  type        = string
  description = "Service name"
  default     = "devops-demo"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service_name))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "owner" {
  type        = string
  description = "Owner/team responsible for resources"
  default     = "devops-team"
}

variable "enable_versioning" {
  type        = bool
  description = "Enable S3 bucket versioning"
  default     = true
}

variable "enable_encryption" {
  type        = bool
  description = "Enable S3 bucket encryption"
  default     = true
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_s3_bucket" "app_state" {
  bucket = "${var.service_name}-${var.environment}-state-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.service_name}-state"
  }
}

resource "aws_s3_bucket_versioning" "app_state" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.app_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_state" {
  count  = var.enable_encryption ? 1 : 0
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

resource "aws_s3_bucket_lifecycle_configuration" "app_state" {
  bucket = aws_s3_bucket.app_state.id

  rule {
    id     = "transition-old-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_iam_role" "app_role" {
  name               = "${var.service_name}-${var.environment}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "${var.service_name}-role"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.service_name]
    }
  }
}

resource "aws_iam_role_policy" "app_s3_access" {
  name   = "s3-access"
  role   = aws_iam_role.app_role.id
  policy = data.aws_iam_policy_document.s3_access.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.app_state.arn,
      "${aws_s3_bucket.app_state.arn}/*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/${var.service_name}/${var.environment}"
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = {
    Name = "${var.service_name}-logs"
  }
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.app_state.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.app_state.arn
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.app_role.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app_logs.name
}
