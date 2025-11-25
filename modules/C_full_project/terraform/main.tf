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
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stage/prod)"
  default     = "dev"
}

variable "service_name" {
  type        = string
  description = "Service name"
  default     = "devops-demo"
}

resource "aws_s3_bucket" "app_state" {
  bucket = "${var.service_name}-${var.environment}-state"
}

resource "aws_iam_role" "app_role" {
  name = "${var.service_name}-${var.environment}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
