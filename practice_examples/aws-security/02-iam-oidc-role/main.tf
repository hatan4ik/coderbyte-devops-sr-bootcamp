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

variable "repo" {
  type        = string
  description = "GitHub org/repo (e.g., your-org/your-repo)"
}

variable "branch" {
  type        = string
  default     = "main"
  description = "Branch to allow"
}

variable "bucket" {
  type        = string
  description = "S3 bucket CI can access"
}

locals {
  oidc_url    = "https://token.actions.githubusercontent.com"
  oidc_thumb  = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-02"
    Environment = "lab"
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = local.oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = local.oidc_thumb
}

resource "aws_iam_role" "ci_oidc_role" {
  name               = "ci-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "oidc_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repo}:ref:refs/heads/${var.branch}"]
    }
  }
}

resource "aws_iam_policy" "ci_bucket_access" {
  name   = "ci-bucket-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::${var.bucket}",
          "arn:aws:s3:::${var.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_attach" {
  role       = aws_iam_role.ci_oidc_role.name
  policy_arn = aws_iam_policy.ci_bucket_access.arn
}

output "role_arn" {
  value = aws_iam_role.ci_oidc_role.arn
}
