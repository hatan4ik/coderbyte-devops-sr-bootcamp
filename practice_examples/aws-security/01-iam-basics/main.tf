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

variable "allowed_bucket" {
  type        = string
  description = "Bucket name the dev group can access"
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-01"
    Environment = "lab"
  }
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_user" "devuser" {
  name = "devuser"
  tags = local.tags
}

resource "aws_iam_user_group_membership" "dev" {
  user = aws_iam_user.devuser.name
  groups = [aws_iam_group.developers.name]
}

resource "aws_iam_group_policy" "dev_s3_limited" {
  name  = "dev-s3-limited"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = ["arn:aws:s3:::${var.allowed_bucket}"]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = ["arn:aws:s3:::${var.allowed_bucket}/*"]
      }
    ]
  })
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_symbols                = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  allow_users_to_change_password = true
  hard_expiry                    = false
  password_reuse_prevention      = 24
  max_password_age               = 90
}

resource "aws_iam_policy" "require_mfa" {
  name   = "require-mfa"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = "*",
        Resource = "*",
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "devuser_mfa" {
  user       = aws_iam_user.devuser.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

output "dev_group" {
  value = aws_iam_group.developers.name
}
output "dev_user" {
  value = aws_iam_user.devuser.name
}
output "mfa_policy_arn" {
  value = aws_iam_policy.require_mfa.arn
}
