terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws" version = "~> 5.0" }
    archive = { source = "hashicorp/archive" version = "~> 2.4" }
  }
}

provider "aws" {}

variable "secret_name" {
  type    = string
  default = "demo/rotated-secret"
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-14"
    Environment = "lab"
  }
}

resource "aws_iam_role" "rotation_role" {
  name               = "secrets-rotation-role"
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

resource "aws_iam_role_policy" "rotation_policy" {
  name = "secrets-rotation-policy"
  role = aws_iam_role.rotation_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = aws_secretsmanager_secret.secret.arn
      },
      {
        Effect = "Allow",
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_secretsmanager_secret" "secret" {
  name       = var.secret_name
  kms_key_id = null
  tags       = local.tags
}

resource "aws_secretsmanager_secret_version" "initial" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({ username = "admin", password = "changeme" })
}

resource "archive_file" "rotation_zip" {
  type        = "zip"
  source_file = "rotation.py"
  output_path = "rotation.zip"
}

resource "aws_lambda_function" "rotation" {
  function_name    = "secret-rotation-fn"
  role             = aws_iam_role.rotation_role.arn
  handler          = "rotation.handler"
  runtime          = "python3.11"
  filename         = archive_file.rotation_zip.output_path
  source_code_hash = archive_file.rotation_zip.output_base64sha256
  timeout          = 60
  tags             = local.tags
}

resource "aws_secretsmanager_secret_rotation" "rotation" {
  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn
  rotation_rules {
    automatically_after_days = 30
  }
}

output "secret_arn" { value = aws_secretsmanager_secret.secret.arn }
output "rotation_lambda" { value = aws_lambda_function.rotation.function_name }
