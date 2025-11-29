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
  default_tags {
    tags = {
      Project     = "IaCSecurityExam"
      ManagedBy   = "Terraform"
      Environment = var.environment
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
  description = "Environment name"
  default     = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Must be dev, stage, or prod"
  }
}

variable "owner" {
  type        = string
  description = "Resource owner"
  default     = "security-team"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR block allowed for SSH access"
  default     = "10.0.0.0/8"
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "Must be valid CIDR block"
  }
}

data "aws_caller_identity" "current" {}

# Hardened S3 bucket
resource "aws_s3_bucket" "secure" {
  bucket = "secure-bucket-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "secure" {
  bucket = aws_s3_bucket.secure.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure" {
  bucket = aws_s3_bucket.secure.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "secure" {
  bucket                  = aws_s3_bucket.secure.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "secure" {
  bucket = aws_s3_bucket.secure.id
  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Secure security group
resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for application with restricted access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from allowed CIDR"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_ssh_cidr
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS from anywhere"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# VPC for security group
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Least privilege IAM role
resource "aws_iam_role" "app" {
  name               = "${var.environment}-app-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags = {
    Purpose = "Application runtime role with least privilege"
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "app" {
  name   = "s3-read-only"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app.json
}

data "aws_iam_policy_document" "app" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.secure.arn,
      "${aws_s3_bucket.secure.arn}/*"
    ]
  }
}

output "bucket_name" {
  value = aws_s3_bucket.secure.id
}

output "security_group_id" {
  value = aws_security_group.app.id
}

output "iam_role_arn" {
  value = aws_iam_role.app.arn
}
