terraform {
  required_version = ">= 1.5"
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
      ManagedBy = "Terraform"
      Purpose   = "ABAC-Demo"
    }
  }
}

# ABAC IAM Role for Developers
resource "aws_iam_role" "developer_abac" {
  name               = "DeveloperABACRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "Developer ABAC Role"
  }
}

# Assume role policy with session tags
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_saml_provider.corporate_idp.arn]
    }
    actions = ["sts:AssumeRoleWithSAML"]
    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

# ABAC Policy - Tag-based access control
resource "aws_iam_role_policy" "abac_policy" {
  name   = "ABACPolicy"
  role   = aws_iam_role.developer_abac.id
  policy = data.aws_iam_policy_document.abac.json
}

data "aws_iam_policy_document" "abac" {
  # EC2 access based on matching tags
  statement {
    sid    = "EC2ABACAccess"
    effect = "Allow"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Project"
      values   = ["$${aws:PrincipalTag/Project}"]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Environment"
      values   = ["$${aws:PrincipalTag/Environment}"]
    }
  }

  # S3 access based on matching tags
  statement {
    sid    = "S3ABACAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Project"
      values   = ["$${aws:PrincipalTag/Project}"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Environment"
      values   = ["$${aws:PrincipalTag/Environment}"]
    }
  }

  # RDS access based on matching tags
  statement {
    sid    = "RDSABACAccess"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:StartDBInstance",
      "rds:StopDBInstance"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "rds:db-tag/Project"
      values   = ["$${aws:PrincipalTag/Project}"]
    }
    condition {
      test     = "StringEquals"
      variable = "rds:db-tag/Environment"
      values   = ["$${aws:PrincipalTag/Environment}"]
    }
  }

  # Lambda access based on matching tags
  statement {
    sid    = "LambdaABACAccess"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunction",
      "lambda:UpdateFunctionCode"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "lambda:ResourceTag/Project"
      values   = ["$${aws:PrincipalTag/Project}"]
    }
    condition {
      test     = "StringEquals"
      variable = "lambda:ResourceTag/Environment"
      values   = ["$${aws:PrincipalTag/Environment}"]
    }
  }

  # Read-only access to all resources for visibility
  statement {
    sid    = "ReadOnlyAccess"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "s3:ListAllMyBuckets",
      "rds:Describe*",
      "lambda:List*"
    ]
    resources = ["*"]
  }

  # Deny production access for non-prod principals
  statement {
    sid    = "DenyProdAccess"
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = ["prod"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalTag/Environment"
      values   = ["prod"]
    }
  }
}

# SAML Provider for federation
resource "aws_iam_saml_provider" "corporate_idp" {
  name                   = "CorporateIDP"
  saml_metadata_document = file("${path.module}/saml-metadata.xml")
}

# Example tagged resources
resource "aws_s3_bucket" "project_alpha_dev" {
  bucket = "project-alpha-dev-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project     = "Alpha"
    Environment = "dev"
  }
}

resource "aws_s3_bucket" "project_beta_dev" {
  bucket = "project-beta-dev-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project     = "Beta"
    Environment = "dev"
  }
}

# CloudTrail for audit
resource "aws_cloudtrail" "abac_audit" {
  name                          = "abac-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = {
    Name = "ABAC Audit Trail"
  }
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "abac-cloudtrail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json
}

data "aws_iam_policy_document" "cloudtrail_bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

data "aws_caller_identity" "current" {}

variable "region" {
  type    = string
  default = "us-east-1"
}

output "role_arn" {
  value       = aws_iam_role.developer_abac.arn
  description = "ARN of the ABAC role"
}

output "saml_provider_arn" {
  value       = aws_iam_saml_provider.corporate_idp.arn
  description = "ARN of the SAML provider"
}

output "cloudtrail_name" {
  value       = aws_cloudtrail.abac_audit.name
  description = "Name of CloudTrail for audit"
}
