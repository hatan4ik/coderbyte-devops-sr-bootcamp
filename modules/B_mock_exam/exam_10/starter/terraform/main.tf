terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # DevOps: In a real-world scenario, the backend would be configured here
  # to store state remotely and securely.
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "exam10/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "your-terraform-lock-table"
  # }
}

provider "aws" {
  region = "us-east-1"
}
