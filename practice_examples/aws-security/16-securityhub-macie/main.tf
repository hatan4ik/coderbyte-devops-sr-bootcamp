terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
  }
}

provider "aws" {}

variable "macie_bucket" {
  type        = string
  description = "Optional S3 bucket to classify with Macie"
  default     = ""
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-16"
    Environment = "lab"
  }
}

resource "aws_securityhub_account" "hub" {
  enable_default_standards = false
  tags = local.tags
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.hub]
}

resource "aws_securityhub_standards_subscription" "foundational" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.hub]
}

data "aws_region" "current" {}

resource "aws_macie2_account" "macie" {
  count  = var.macie_bucket == "" ? 0 : 1
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status = "ENABLED"
}

resource "aws_macie2_classification_job" "job" {
  count       = var.macie_bucket == "" ? 0 : 1
  job_type    = "ONE_TIME"
  name        = "classify-${replace(var.macie_bucket, "/", "-")}"
  description = "Classify sensitive data in ${var.macie_bucket}"

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [var.macie_bucket]
    }
  }

  depends_on = [aws_macie2_account.macie]
  tags       = local.tags
}

data "aws_caller_identity" "current" {}

output "securityhub_enabled" { value = true }
output "macie_job" { value = var.macie_bucket == "" ? "not created" : aws_macie2_classification_job.job[0].name }
