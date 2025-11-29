terraform {
  required_version = ">= 1.5"
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

# DynamoDB Table - Single Table Design
resource "aws_dynamodb_table" "saas_platform" {
  name           = "saas-platform-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb.arn
  }

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  attribute {
    name = "GSI2PK"
    type = "S"
  }

  attribute {
    name = "GSI2SK"
    type = "S"
  }

  # GSI1: User email lookup and user's orders
  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  # GSI2: Category/Status queries
  global_secondary_index {
    name            = "GSI2"
    hash_key        = "GSI2PK"
    range_key       = "GSI2SK"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  tags = {
    Name        = "saas-platform-table"
    Environment = var.environment
  }
}

# KMS Key for encryption
resource "aws_kms_key" "dynamodb" {
  description             = "KMS key for DynamoDB encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "dynamodb-encryption-key"
  }
}

resource "aws_kms_alias" "dynamodb" {
  name          = "alias/dynamodb-${var.environment}"
  target_key_id = aws_kms_key.dynamodb.key_id
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "read_throttle" {
  alarm_name          = "dynamodb-read-throttle-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "DynamoDB read throttle events"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TableName = aws_dynamodb_table.saas_platform.name
  }
}

resource "aws_cloudwatch_metric_alarm" "write_throttle" {
  alarm_name          = "dynamodb-write-throttle-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "DynamoDB write throttle events"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TableName = aws_dynamodb_table.saas_platform.name
  }
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "dynamodb-alerts-${var.environment}"

  tags = {
    Name = "DynamoDB Alerts"
  }
}

# Lambda for Stream Processing
resource "aws_lambda_function" "stream_processor" {
  filename      = "stream_processor.zip"
  function_name = "dynamodb-stream-processor-${var.environment}"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 512

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.saas_platform.name
    }
  }

  tags = {
    Name = "DynamoDB Stream Processor"
  }
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.saas_platform.stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
  batch_size        = 100

  filter_criteria {
    filter {
      pattern = jsonencode({
        eventName = ["INSERT", "MODIFY"]
      })
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "dynamodb-stream-processor-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Resource = aws_dynamodb_table.saas_platform.stream_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Backup Vault
resource "aws_backup_vault" "dynamodb" {
  name        = "dynamodb-backup-vault-${var.environment}"
  kms_key_arn = aws_kms_key.dynamodb.arn

  tags = {
    Name = "DynamoDB Backup Vault"
  }
}

# Backup Plan
resource "aws_backup_plan" "dynamodb" {
  name = "dynamodb-backup-plan-${var.environment}"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.dynamodb.name
    schedule          = "cron(0 2 * * ? *)"

    lifecycle {
      delete_after = 30
    }
  }

  rule {
    rule_name         = "weekly_backup"
    target_vault_name = aws_backup_vault.dynamodb.name
    schedule          = "cron(0 3 ? * 1 *)"

    lifecycle {
      delete_after = 90
    }
  }
}

resource "aws_backup_selection" "dynamodb" {
  name         = "dynamodb-backup-selection"
  plan_id      = aws_backup_plan.dynamodb.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [
    aws_dynamodb_table.saas_platform.arn
  ]
}

resource "aws_iam_role" "backup" {
  name = "dynamodb-backup-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "prod"
}

output "table_name" {
  value = aws_dynamodb_table.saas_platform.name
}

output "table_arn" {
  value = aws_dynamodb_table.saas_platform.arn
}

output "stream_arn" {
  value = aws_dynamodb_table.saas_platform.stream_arn
}
