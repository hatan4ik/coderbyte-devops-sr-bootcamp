terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # This would be configured for a real environment
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
  description = "Deployment environment, e.g. dev/stage/prod"
  default     = "dev"
}

variable "bucket_base_name" {
  type        = string
  description = "Base name for the S3 bucket"
  default     = "app-data"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default = {
    ManagedBy   = "Terraform"
    Project     = "CoderbyteExam01"
    Environment = "dev" # This should match var.environment
  }
}

# Call the reusable S3 bucket module
module "app_bucket" {
  source = "../../../../../modules/aws-s3-bucket" # Adjust path as needed

  bucket_base_name = var.bucket_base_name
  environment      = var.environment
  tags             = var.tags
}
