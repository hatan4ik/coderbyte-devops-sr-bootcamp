terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
  }
}

provider "aws" {}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-13"
    Environment = "lab"
  }
}

resource "aws_iam_policy" "permission_boundary" {
  name   = "pb-restrict"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = [
          "iam:*",
          "s3:*",
          "kms:*"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:ListAllMyBuckets", "s3:ListBucket", "s3:GetObject"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user" "scptest" {
  name                 = "scptest"
  permissions_boundary = aws_iam_policy.permission_boundary.arn
  tags                 = local.tags
}

resource "aws_iam_policy" "scptest_policy" {
  name   = "scptest-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = ["arn:aws:s3:::example-bucket"]
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = ["arn:aws:s3:::example-bucket/*"]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_scptest" {
  user       = aws_iam_user.scptest.name
  policy_arn = aws_iam_policy.scptest_policy.arn
}

resource "aws_iam_policy" "deny_scp_sim" {
  name   = "deny-critical-actions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "guardduty:DeleteDetector",
          "guardduty:DeleteIPSet",
          "guardduty:DeleteThreatIntelSet",
          "guardduty:StopMonitoringMembers"
        ],
        Resource = "*"
      },
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

resource "aws_iam_user_policy_attachment" "attach_deny_scp" {
  user       = aws_iam_user.scptest.name
  policy_arn = aws_iam_policy.deny_scp_sim.arn
}

output "user" { value = aws_iam_user.scptest.name }
output "permission_boundary_arn" { value = aws_iam_policy.permission_boundary.arn }
output "deny_policy_arn" { value = aws_iam_policy.deny_scp_sim.arn }
