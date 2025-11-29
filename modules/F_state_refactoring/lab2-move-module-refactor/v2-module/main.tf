terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Environment = var.environment
      Service     = var.service_name
      Component   = "state-refactor-lab2"
      Owner       = var.owner
    }
  }
}

module "storage" {
  source              = "./modules/storage"
  service_name        = var.service_name
  environment         = var.environment
  owner               = var.owner
  log_retention_days  = var.log_retention_days
}

output "bucket_name" {
  value       = module.storage.bucket_name
  description = "State bucket name"
}

output "log_group" {
  value       = module.storage.log_group
  description = "Log group name"
}
