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
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

module "vpc_primary" {
  source = "./modules/vpc"
  providers = {
    aws = aws.primary
  }
  
  environment = "primary"
  cidr_block  = "10.0.0.0/16"
  azs         = ["${var.primary_region}a", "${var.primary_region}b", "${var.primary_region}c"]
}

module "vpc_dr" {
  source = "./modules/vpc"
  providers = {
    aws = aws.dr
  }
  
  environment = "dr"
  cidr_block  = "10.1.0.0/16"
  azs         = ["${var.dr_region}a", "${var.dr_region}b", "${var.dr_region}c"]
}

resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  bucket   = "${var.app_name}-primary-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_replication_configuration" "primary_to_dr" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  role     = aws_iam_role.replication.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.dr.arn
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket" "dr" {
  provider = aws.dr
  bucket   = "${var.app_name}-dr-${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" "current" {}

variable "primary_region" {
  default = "us-east-1"
}

variable "dr_region" {
  default = "us-west-2"
}

variable "app_name" {
  default = "platform"
}
