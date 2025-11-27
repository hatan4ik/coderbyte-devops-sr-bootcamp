terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
  }
}

provider "aws" {}

variable "project_name" { type = string }
variable "artifact_bucket" {
  type        = string
  description = "Optional S3 bucket for artifacts (set to empty to use NO_ARTIFACTS)"
  default     = ""
}
variable "vpc_config" {
  type = object({
    vpc_id             = optional(string)
    subnets            = optional(list(string))
    security_group_ids = optional(list(string))
  })
  default = {}
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-07"
    Environment = "lab"
  }
}

resource "aws_kms_key" "codebuild" {
  description             = "KMS key for CodeBuild artifacts/logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_s3_bucket" "artifacts" {
  count         = var.artifact_bucket == "" ? 0 : 1
  bucket        = var.artifact_bucket
  force_destroy = false
  tags          = merge(local.tags, { Name = var.project_name })
}

resource "aws_codebuild_project" "secure" {
  name          = var.project_name
  service_role  = aws_iam_role.cb_role.arn
  build_timeout = 30

  encryption_key = aws_kms_key.codebuild.arn

  artifacts {
    type      = var.artifact_bucket == "" ? "NO_ARTIFACTS" : "S3"
    location  = var.artifact_bucket == "" ? null : aws_s3_bucket.artifacts[0].bucket
    packaging = "ZIP"
    encryption_disabled = false
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "LOG_LEVEL"
      value = "INFO"
    }
  }

  source {
    type            = "NO_SOURCE"
    buildspec       = file("buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs { status = "ENABLED" }
    s3_logs {
      status   = var.artifact_bucket == "" ? "DISABLED" : "ENABLED"
      location = var.artifact_bucket == "" ? null : "${aws_s3_bucket.artifacts[0].id}/codebuild-logs"
      encryption_disabled = false
    }
  }

  dynamic "vpc_config" {
    for_each = (try(length(var.vpc_config.subnets), 0) > 0 ? [1] : [])
    content {
      vpc_id              = var.vpc_config.vpc_id
      subnets             = var.vpc_config.subnets
      security_group_ids  = var.vpc_config.security_group_ids
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "cb_role" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.cb_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "cb_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["codebuild.amazonaws.com"] }
  }
}

resource "aws_iam_role_policy" "cb_policy" {
  name = "${var.project_name}-policy"
  role = aws_iam_role.cb_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"],
        Resource = aws_kms_key.codebuild.arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Resource = var.artifact_bucket == "" ? [] : [
          "arn:aws:s3:::${var.artifact_bucket}",
          "arn:aws:s3:::${var.artifact_bucket}/*"
        ]
      }
    ]
  })
}

output "codebuild_project" { value = aws_codebuild_project.secure.name }
