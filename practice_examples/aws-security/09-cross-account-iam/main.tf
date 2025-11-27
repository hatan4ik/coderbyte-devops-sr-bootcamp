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

variable "trusted_account_id" { type = string }
variable "external_id" { type = string }
variable "target_bucket" { type = string }

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-09"
    Environment = "lab"
  }
}

resource "aws_iam_role" "cross_account" {
  name               = "cross-account-reader"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = local.tags
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.trusted_account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

resource "aws_iam_role_policy" "s3_read" {
  name = "cross-account-s3-read"
  role = aws_iam_role.cross_account.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${var.target_bucket}",
          "arn:aws:s3:::${var.target_bucket}/*"
        ]
      }
    ]
  })
}

output "role_arn" { value = aws_iam_role.cross_account.arn }
