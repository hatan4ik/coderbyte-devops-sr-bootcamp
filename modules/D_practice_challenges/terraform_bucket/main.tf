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
  region = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Base bucket name"
}

variable "environment" {
  type        = string
  description = "Environment suffix"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}-${var.environment}"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
