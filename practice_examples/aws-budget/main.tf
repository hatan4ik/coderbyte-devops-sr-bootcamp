terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "email" {
  type        = string
  description = "Email for budget alerts"
}

variable "amount" {
  type    = number
  default = 100.0
}

resource "aws_budgets_budget" "monthly" {
  name              = "practice-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  cost_filters = {}

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type   = "ACTUAL"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    subscriber {
      address          = var.email
      subscription_type = "EMAIL"
    }
  }
}
