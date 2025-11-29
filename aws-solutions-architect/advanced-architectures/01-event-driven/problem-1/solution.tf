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

# EventBridge Custom Bus
resource "aws_cloudwatch_event_bus" "rideshare" {
  name = "rideshare-event-bus"
}

# Event Archive for Compliance
resource "aws_cloudwatch_event_archive" "rideshare" {
  name             = "rideshare-archive"
  event_source_arn = aws_cloudwatch_event_bus.rideshare.arn
  retention_days   = 2555 # 7 years
}

# Schema Registry
resource "aws_schemas_registry" "rideshare" {
  name        = "rideshare-schemas"
  description = "Event schemas for rideshare platform"
}

resource "aws_schemas_schema" "ride_requested" {
  name          = "RideRequested"
  registry_name = aws_schemas_registry.rideshare.name
  type          = "OpenApi3"
  content = jsonencode({
    openapi = "3.0.0"
    info = {
      version = "1.0.0"
      title   = "RideRequested"
    }
    paths = {}
    components = {
      schemas = {
        RideRequested = {
          type = "object"
          required = ["rideId", "customerId", "pickup", "dropoff", "timestamp"]
          properties = {
            rideId     = { type = "string" }
            customerId = { type = "string" }
            pickup     = { type = "object" }
            dropoff    = { type = "object" }
            timestamp  = { type = "string", format = "date-time" }
          }
        }
      }
    }
  })
}

# DLQ for Failed Events
resource "aws_sqs_queue" "dlq" {
  name                      = "rideshare-dlq"
  message_retention_seconds = 1209600 # 14 days
  
  tags = {
    Name = "Rideshare DLQ"
  }
}

# Lambda Functions for Each Service
resource "aws_lambda_function" "ride_service" {
  filename      = "ride_service.zip"
  function_name = "rideshare-ride-service"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.rideshare.name
      TABLE_NAME     = aws_dynamodb_table.rides.name
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
}

resource "aws_lambda_function" "driver_service" {
  filename      = "driver_service.zip"
  function_name = "rideshare-driver-service"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.rideshare.name
      TABLE_NAME     = aws_dynamodb_table.drivers.name
    }
  }
}

resource "aws_lambda_function" "payment_service" {
  filename      = "payment_service.zip"
  function_name = "rideshare-payment-service"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.rideshare.name
    }
  }
}

resource "aws_lambda_function" "fraud_detection" {
  filename      = "fraud_detection.zip"
  function_name = "rideshare-fraud-detection"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 10
  memory_size   = 1024

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.rideshare.name
    }
  }
}

# EventBridge Rules
resource "aws_cloudwatch_event_rule" "ride_requested" {
  name           = "ride-requested"
  event_bus_name = aws_cloudwatch_event_bus.rideshare.name
  
  event_pattern = jsonencode({
    source      = ["rideshare.rides"]
    detail-type = ["RideRequested"]
  })
}

resource "aws_cloudwatch_event_target" "ride_to_driver" {
  rule           = aws_cloudwatch_event_rule.ride_requested.name
  event_bus_name = aws_cloudwatch_event_bus.rideshare.name
  arn            = aws_lambda_function.driver_service.arn
  
  retry_policy {
    maximum_retry_attempts = 3
    maximum_event_age      = 3600
  }
  
  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }
}

resource "aws_cloudwatch_event_target" "ride_to_fraud" {
  rule           = aws_cloudwatch_event_rule.ride_requested.name
  event_bus_name = aws_cloudwatch_event_bus.rideshare.name
  arn            = aws_lambda_function.fraud_detection.arn
}

resource "aws_cloudwatch_event_rule" "ride_completed" {
  name           = "ride-completed"
  event_bus_name = aws_cloudwatch_event_bus.rideshare.name
  
  event_pattern = jsonencode({
    source      = ["rideshare.rides"]
    detail-type = ["RideCompleted"]
  })
}

resource "aws_cloudwatch_event_target" "completed_to_payment" {
  rule           = aws_cloudwatch_event_rule.ride_completed.name
  event_bus_name = aws_cloudwatch_event_bus.rideshare.name
  arn            = aws_lambda_function.payment_service.arn
}

# Lambda Permissions
resource "aws_lambda_permission" "eventbridge_ride" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ride_service.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ride_requested.arn
}

resource "aws_lambda_permission" "eventbridge_driver" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.driver_service.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ride_requested.arn
}

resource "aws_lambda_permission" "eventbridge_payment" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.payment_service.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ride_completed.arn
}

resource "aws_lambda_permission" "eventbridge_fraud" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fraud_detection.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ride_requested.arn
}

# DynamoDB Tables
resource "aws_dynamodb_table" "rides" {
  name           = "rideshare-rides"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "rideId"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "rideId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "drivers" {
  name         = "rideshare-drivers"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "driverId"

  attribute {
    name = "driverId"
    type = "S"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "rideshare-lambda-role"

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

resource "aws_iam_role_policy" "lambda" {
  name = "lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = aws_cloudwatch_event_bus.rideshare.arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.rides.arn,
          aws_dynamodb_table.drivers.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.dlq.arn
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

variable "region" {
  type    = string
  default = "us-east-1"
}

output "event_bus_name" {
  value = aws_cloudwatch_event_bus.rideshare.name
}

output "event_bus_arn" {
  value = aws_cloudwatch_event_bus.rideshare.arn
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}
