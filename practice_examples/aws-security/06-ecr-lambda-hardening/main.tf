terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {}

variable "lambda_name" {
  type    = string
  default = "secure-lambda"
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-06"
    Environment = "lab"
  }
}

resource "aws_ecr_repository" "repo" {
  name                 = "secure-ecr-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1,
          description  = "Expire untagged after 7 days",
          selection    = {
            tagStatus   = "untagged",
            countType   = "sinceImagePushed",
            countUnit   = "days",
            countNumber = 7
          },
          action = { type = "expire" }
        }
      ]
    })
  }

  tags = merge(local.tags, { Name = "secure-ecr-repo" })
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["lambda.amazonaws.com"] }
  }
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "fn" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.handler"
  runtime       = "python3.11"
  filename      = archive_file.lambda_zip.output_path
  source_code_hash = archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = local.tags
}

output "ecr_repo_url" { value = aws_ecr_repository.repo.repository_url }
output "lambda_name" { value = aws_lambda_function.fn.function_name }
