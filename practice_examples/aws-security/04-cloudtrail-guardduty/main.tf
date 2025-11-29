terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

variable "trail_bucket" {
  type        = string
  description = "S3 bucket name for CloudTrail logs"
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-04"
    Environment = "lab"
  }
}

resource "aws_s3_bucket" "trail" {
  bucket        = var.trail_bucket
  force_destroy = false
  tags          = merge(local.tags, { Name = "trail-bucket" })
}

resource "aws_s3_bucket_versioning" "trail" {
  bucket = aws_s3_bucket.trail.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.trail.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket = aws_s3_bucket.trail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudtrail" "main" {
  name           = "aws-security-lab-04"
  s3_bucket_name = aws_s3_bucket.trail.id
  is_multi_region_trail = true
  include_global_service_events = true
  enable_log_file_validation    = true
  event_selector {
    read_write_type = "All"
    include_management_events = true
  }
  tags = local.tags
}

resource "aws_guardduty_detector" "main" {
  enable = true
  datasources {
    s3_logs { enable = true }
    kubernetes { audit_logs { enable = true } }
    malware_protection { scan_ec2_instance_with_findings { ebs_volumes = true } }
  }
  tags = local.tags
}

output "trail_arn" { value = aws_cloudtrail.main.arn }
output "guardduty_detector_id" { value = aws_guardduty_detector.main.id }
