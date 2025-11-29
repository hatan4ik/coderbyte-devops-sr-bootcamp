terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Kinesis Data Stream
resource "aws_kinesis_stream" "clickstream" {
  name             = "clickstream"
  shard_count      = 10
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

# Kinesis Data Analytics
resource "aws_kinesisanalyticsv2_application" "analytics" {
  name                   = "clickstream-analytics"
  runtime_environment    = "FLINK-1_15"
  service_execution_role = aws_iam_role.analytics.arn

  application_configuration {
    application_code_configuration {
      code_content {
        text_content = file("${path.module}/analytics.sql")
      }
      code_content_type = "PLAINTEXT"
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type = "DEFAULT"
      }
    }
  }
}

# Kinesis Firehose to S3
resource "aws_kinesis_firehose_delivery_stream" "s3" {
  name        = "clickstream-to-s3"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.clickstream.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.datalake.arn
    prefix     = "clickstream/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

    processing_configuration {
      enabled = true
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.transform.arn}:$LATEST"
        }
      }
    }

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }
      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }
      schema_configuration {
        database_name = aws_glue_catalog_database.clickstream.name
        table_name    = aws_glue_catalog_table.clickstream.name
        role_arn      = aws_iam_role.firehose.arn
      }
    }
  }
}

# Lambda for real-time processing
resource "aws_lambda_function" "processor" {
  filename      = "processor.zip"
  function_name = "clickstream-processor"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 1024

  environment {
    variables = {
      AGGREGATES_TABLE = aws_dynamodb_table.aggregates.name
    }
  }
}

resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn  = aws_kinesis_stream.clickstream.arn
  function_name     = aws_lambda_function.processor.arn
  starting_position = "LATEST"
  batch_size        = 100
}

# Lambda for Firehose transformation
resource "aws_lambda_function" "transform" {
  filename      = "transform.zip"
  function_name = "firehose-transform"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 60
}

# DynamoDB for aggregates
resource "aws_dynamodb_table" "aggregates" {
  name         = "clickstream-aggregates"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "windowKey"
  range_key    = "timestamp"

  attribute {
    name = "windowKey"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "N"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }
}

# S3 Data Lake
resource "aws_s3_bucket" "datalake" {
  bucket = "clickstream-datalake-${data.aws_caller_identity.current.account_id}"
}

# Glue Catalog
resource "aws_glue_catalog_database" "clickstream" {
  name = "clickstream"
}

resource "aws_glue_catalog_table" "clickstream" {
  name          = "events"
  database_name = aws_glue_catalog_database.clickstream.name

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.datalake.bucket}/clickstream/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "event_id"
      type = "string"
    }
    columns {
      name = "user_id"
      type = "string"
    }
    columns {
      name = "event_type"
      type = "string"
    }
    columns {
      name = "timestamp"
      type = "bigint"
    }
  }
}

# IAM Roles
resource "aws_iam_role" "analytics" {
  name = "kinesis-analytics-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "kinesisanalytics.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "firehose" {
  name = "firehose-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "firehose" {
  role = aws_iam_role.firehose.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:*", "kinesis:*", "lambda:InvokeFunction", "glue:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda" {
  name = "lambda-kinesis-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda" {
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kinesis:*", "dynamodb:*", "logs:*"]
        Resource = "*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

output "stream_name" {
  value = aws_kinesis_stream.clickstream.name
}
