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

variable "department" {
  type    = string
  default = "engineering"
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-10"
    Environment = "lab"
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "AWS"
      identifiers = ["*"] # replace with your IdP principal/role
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/department"
      values   = [var.department]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:TagKeys"
      values   = ["department"]
    }
  }
}

resource "aws_iam_role" "abac" {
  name               = "abac-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = merge(local.tags, { department = var.department })
}

resource "aws_iam_role_policy" "abac_policy" {
  name = "abac-s3-policy"
  role = aws_iam_role.abac.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:ResourceTag/department" = "${var.department}"
          }
        }
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:ResourceTag/department" = "${var.department}",
            "aws:PrincipalTag/department" = "${var.department}"
          }
        }
      }
    ]
  })
}

output "role_arn" { value = aws_iam_role.abac.arn }
