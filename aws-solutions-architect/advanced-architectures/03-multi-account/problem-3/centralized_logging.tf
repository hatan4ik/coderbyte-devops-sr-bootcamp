terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  alias  = "logging"
  region = "us-east-1"
}

# Kinesis Data Stream for log aggregation
resource "aws_kinesis_stream" "logs" {
  provider         = aws.logging
  name             = "centralized-logs"
  shard_count      = 5
  retention_period = 24
}

# Kinesis Firehose to S3
resource "aws_kinesis_firehose_delivery_stream" "logs_to_s3" {
  provider    = aws.logging
  name        = "logs-to-s3"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.logs.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.logs.arn
    prefix     = "logs/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = "S3Delivery"
    }
  }
}

# S3 bucket for logs
resource "aws_s3_bucket" "logs" {
  provider = aws.logging
  bucket   = "centralized-logs-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  provider = aws.logging
  bucket   = aws_s3_bucket.logs.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 2555 # 7 years
    }
  }
}

# CloudWatch Log Group for Firehose
resource "aws_cloudwatch_log_group" "firehose" {
  provider          = aws.logging
  name              = "/aws/kinesisfirehose/logs-to-s3"
  retention_in_days = 7
}

# IAM Role for Firehose
resource "aws_iam_role" "firehose" {
  provider = aws.logging
  name     = "firehose-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "firehose" {
  provider = aws.logging
  role     = aws_iam_role.firehose.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords"
        ]
        Resource = aws_kinesis_stream.logs.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.firehose.arn}:*"
      }
    ]
  })
}

# Glue Catalog for Athena queries
resource "aws_glue_catalog_database" "logs" {
  provider = aws.logging
  name     = "centralized_logs"
}

resource "aws_glue_catalog_table" "application_logs" {
  provider      = aws.logging
  name          = "application_logs"
  database_name = aws_glue_catalog_database.logs.name

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.logs.bucket}/logs/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "timestamp"
      type = "string"
    }
    columns {
      name = "level"
      type = "string"
    }
    columns {
      name = "message"
      type = "string"
    }
    columns {
      name = "account_id"
      type = "string"
    }
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }
}

# IAM Role for cross-account log subscription
resource "aws_iam_role" "log_subscription" {
  provider = aws.logging
  name     = "cross-account-log-subscription"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "log_subscription" {
  provider = aws.logging
  role     = aws_iam_role.log_subscription.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ]
      Resource = aws_kinesis_stream.logs.arn
    }]
  })
}

data "aws_caller_identity" "current" {
  provider = aws.logging
}

output "kinesis_stream_arn" {
  value = aws_kinesis_stream.logs.arn
}

output "log_subscription_role_arn" {
  value = aws_iam_role.log_subscription.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.logs.bucket
}
