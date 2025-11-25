terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Intentional misconfigurations to harden during the exam.
resource "aws_s3_bucket" "artifacts" {
  bucket = "iac-security-artifacts-${var.environment}"
  acl    = "public-read" # TODO: tighten access

  tags = {
    Environment = var.environment
    Owner       = "devops"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "iac-security-app-sg-${var.environment}"
  description = "Allow app + SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: restrict
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: review
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "app_role" {
  name               = "iac-security-app-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "app_role_policy" {
  name = "iac-security-app-policy-${var.environment}"
  role = aws_iam_role.app_role.id

  # TODO: least privilege
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
    }
  }
}
