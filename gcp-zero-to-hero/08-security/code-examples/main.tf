terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Production-ready remote state configuration for team collaboration and security.
  # State is stored in S3 with locking via DynamoDB to prevent concurrent modifications.
  backend "s3" {
    # These values would be configured via a backend configuration file or CLI arguments
    # for different environments (e.g., dev, staging, prod).
    # Example for CLI:
    # terraform init -backend-config="bucket=my-tf-state-bucket" -backend-config="key=exam10/terraform.tfstate" ...
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Variables ---

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Note: The backend block itself does not support variables directly.
# You must use partial configuration with `-backend-config` flags in your CI/CD pipeline.
