terraform {
  required_version = ">= 1.6.0"

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

  backend "s3" {
    encrypt        = true
    kms_key_id     = "alias/terraform-state"
    dynamodb_table = "terraform-state-lock"
  }
}

# Multi-region provider configuration
provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }

  assume_role {
    role_arn     = var.assume_role_arn
    session_name = "terraform-${var.service_name}"
  }
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region

  default_tags {
    tags = local.common_tags
  }
}

# Local values for DRY principle
locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Service     = var.service_name
      ManagedBy   = "Terraform"
      Owner       = var.owner
      CostCenter  = var.cost_center
      Compliance  = var.compliance_level
    }
  )

  bucket_name = "${var.service_name}-${var.environment}-${random_id.suffix.hex}"
  
  is_production = var.environment == "prod"
  
  retention_days = local.is_production ? 90 : 30
  
  kms_key_admins = concat(
    [data.aws_caller_identity.current.arn],
    var.kms_key_admins
  )
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# Random suffix for global uniqueness
resource "random_id" "suffix" {
  byte_length = 4
}

# KMS key for encryption at rest
resource "aws_kms_key" "app" {
  description             = "KMS key for ${var.service_name} ${var.environment}"
  deletion_window_in_days = local.is_production ? 30 : 7
  enable_key_rotation     = true
  multi_region            = var.enable_multi_region

  policy = data.aws_iam_policy_document.kms_key_policy.json

  tags = {
    Name = "${var.service_name}-kms-key"
  }
}

resource "aws_kms_alias" "app" {
  name          = "alias/${var.service_name}-${var.environment}"
  target_key_id = aws_kms_key.app.key_id
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = local.kms_key_admins
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Service Usage"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com",
        "logs.amazonaws.com",
        "cloudwatch.amazonaws.com"
      ]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

# S3 bucket with advanced security
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"

  bucket = local.bucket_name

  # Versioning
  versioning = {
    enabled    = var.enable_versioning
    mfa_delete = local.is_production
  }

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.app.arn
      }
      bucket_key_enabled = true
    }
  }

  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Lifecycle rules
  lifecycle_rule = [
    {
      id      = "intelligent-tiering"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "INTELLIGENT_TIERING"
        }
      ]
    },
    {
      id      = "archive-old-versions"
      enabled = var.enable_versioning

      noncurrent_version_transition = [
        {
          noncurrent_days = 30
          storage_class   = "STANDARD_IA"
        },
        {
          noncurrent_days = 90
          storage_class   = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        noncurrent_days = local.retention_days
      }
    }
  ]

  # Replication for DR
  replication_configuration = var.enable_replication ? {
    role = aws_iam_role.replication[0].arn

    rules = [
      {
        id       = "replicate-to-dr"
        status   = "Enabled"
        priority = 10

        destination = {
          bucket        = module.s3_bucket_dr[0].s3_bucket_arn
          storage_class = "STANDARD_IA"
          
          encryption_configuration = {
            replica_kms_key_id = aws_kms_key.app_dr[0].arn
          }
        }

        filter = {
          prefix = ""
        }
      }
    ]
  } : null

  # Logging
  logging = {
    target_bucket = aws_s3_bucket.access_logs.id
    target_prefix = "${var.service_name}/"
  }

  # Object lock for compliance
  object_lock_enabled = local.is_production && var.compliance_level == "high"

  tags = {
    Name = "${var.service_name}-bucket"
  }
}

# Access logs bucket
resource "aws_s3_bucket" "access_logs" {
  bucket = "${local.bucket_name}-logs"

  tags = {
    Name = "${var.service_name}-access-logs"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# DR bucket (conditional)
module "s3_bucket_dr" {
  count   = var.enable_replication ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"

  providers = {
    aws = aws.dr
  }

  bucket = "${local.bucket_name}-dr"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.app_dr[0].arn
      }
    }
  }

  tags = {
    Name = "${var.service_name}-bucket-dr"
  }
}

# DR KMS key
resource "aws_kms_key" "app_dr" {
  count    = var.enable_replication ? 1 : 0
  provider = aws.dr

  description             = "DR KMS key for ${var.service_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key_policy.json
}

# Replication IAM role
resource "aws_iam_role" "replication" {
  count = var.enable_replication ? 1 : 0
  name  = "${var.service_name}-${var.environment}-replication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "replication" {
  count = var.enable_replication ? 1 : 0
  role  = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = module.s3_bucket.s3_bucket_arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl"
        ]
        Resource = "${module.s3_bucket.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ]
        Resource = "${module.s3_bucket_dr[0].s3_bucket_arn}/*"
      }
    ]
  })
}

# IAM role with least privilege
resource "aws_iam_role" "app" {
  name                 = "${var.service_name}-${var.environment}-role"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json

  permissions_boundary = var.permissions_boundary_arn

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

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.allowed_source_ips
    }
  }
}

# Least privilege S3 access
resource "aws_iam_role_policy" "app_s3" {
  name   = "s3-access"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.s3_access.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [module.s3_bucket.s3_bucket_arn]
  }

  statement {
    sid    = "ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [aws_kms_key.app.arn]
  }
}

# CloudWatch Logs with encryption
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/${var.service_name}/${var.environment}"
  retention_in_days = local.retention_days
  kms_key_id        = aws_kms_key.app.arn

  tags = {
    Name = "${var.service_name}-logs"
  }
}

# CloudWatch metric alarms
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.service_name}-${var.environment}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "High error rate detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = var.service_name
  }
}

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name              = "${var.service_name}-${var.environment}-alerts"
  kms_master_key_id = aws_kms_key.app.id

  tags = {
    Name = "${var.service_name}-alerts"
  }
}

# Outputs with sensitive handling
output "bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_bucket.s3_bucket_arn
  sensitive   = false
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.app.key_id
  sensitive   = true
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.app.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app.name
}
