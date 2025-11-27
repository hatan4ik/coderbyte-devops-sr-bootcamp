terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
  }
}

provider "aws" {}

variable "resource_arn" {
  type        = string
  description = "Optional ARN to associate the WebACL (ALB/CloudFront/API Gateway)."
  default     = ""
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-15"
    Environment = "lab"
  }
}

resource "aws_wafv2_web_acl" "main" {
  name        = "managed-web-acl"
  description = "Managed rules for ALB/CF"
  scope       = "REGIONAL" # use CLOUDFRONT for CF

  default_action { allow {} }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    statement { managed_rule_group_statement { name = "AWSManagedRulesCommonRuleSet" vendor_name = "AWS" } }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    statement { managed_rule_group_statement { name = "AWSManagedRulesKnownBadInputsRuleSet" vendor_name = "AWS" } }
    override_action { none {} }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "badinputs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webacl"
    sampled_requests_enabled   = true
  }

  tags = local.tags
}

resource "aws_wafv2_web_acl_association" "assoc" {
  count        = var.resource_arn == "" ? 0 : 1
  resource_arn = var.resource_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

output "web_acl_arn" { value = aws_wafv2_web_acl.main.arn }
