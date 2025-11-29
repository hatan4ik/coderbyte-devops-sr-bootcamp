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

# Event Store - Immutable event log
resource "aws_dynamodb_table" "event_store" {
  name           = "event-store"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "aggregateId"
  range_key      = "version"
  stream_enabled = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "aggregateId"
    type = "S"
  }

  attribute {
    name = "version"
    type = "N"
  }

  attribute {
    name = "eventType"
    type = "S"
  }

  global_secondary_index {
    name            = "EventTypeIndex"
    hash_key        = "eventType"
    range_key       = "version"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }
}

# Read Model - Orders
resource "aws_dynamodb_table" "orders_read" {
  name         = "orders-read-model"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "orderId"

  attribute {
    name = "orderId"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "CustomerIndex"
    hash_key        = "customerId"
    range_key       = "orderId"
    projection_type = "ALL"
  }
}

# Read Model - Inventory
resource "aws_dynamodb_table" "inventory_read" {
  name         = "inventory-read-model"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "productId"

  attribute {
    name = "productId"
    type = "S"
  }
}

# Command Handler Lambda
resource "aws_lambda_function" "command_handler" {
  filename      = "command_handler.zip"
  function_name = "cqrs-command-handler"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      EVENT_STORE_TABLE = aws_dynamodb_table.event_store.name
    }
  }
}

# Event Projector Lambda
resource "aws_lambda_function" "projector" {
  filename      = "projector.zip"
  function_name = "cqrs-projector"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 1024

  environment {
    variables = {
      ORDERS_TABLE     = aws_dynamodb_table.orders_read.name
      INVENTORY_TABLE  = aws_dynamodb_table.inventory_read.name
    }
  }
}

# DynamoDB Stream to Lambda
resource "aws_lambda_event_source_mapping" "event_stream" {
  event_source_arn  = aws_dynamodb_table.event_store.stream_arn
  function_name     = aws_lambda_function.projector.arn
  starting_position = "LATEST"
  batch_size        = 100
}

# Query API Lambda
resource "aws_lambda_function" "query_api" {
  filename      = "query_api.zip"
  function_name = "cqrs-query-api"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      ORDERS_TABLE    = aws_dynamodb_table.orders_read.name
      INVENTORY_TABLE = aws_dynamodb_table.inventory_read.name
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "cqrs" {
  name          = "cqrs-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "command" {
  api_id           = aws_apigatewayv2_api.cqrs.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.command_handler.invoke_arn
}

resource "aws_apigatewayv2_integration" "query" {
  api_id           = aws_apigatewayv2_api.cqrs.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.query_api.invoke_arn
}

resource "aws_apigatewayv2_route" "command" {
  api_id    = aws_apigatewayv2_api.cqrs.id
  route_key = "POST /commands/{command}"
  target    = "integrations/${aws_apigatewayv2_integration.command.id}"
}

resource "aws_apigatewayv2_route" "query" {
  api_id    = aws_apigatewayv2_api.cqrs.id
  route_key = "GET /queries/{query}"
  target    = "integrations/${aws_apigatewayv2_integration.query.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.cqrs.id
  name        = "prod"
  auto_deploy = true
}

# IAM Role
resource "aws_iam_role" "lambda" {
  name = "cqrs-lambda-role"

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
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Resource = [
          aws_dynamodb_table.event_store.arn,
          "${aws_dynamodb_table.event_store.arn}/*",
          aws_dynamodb_table.orders_read.arn,
          "${aws_dynamodb_table.orders_read.arn}/*",
          aws_dynamodb_table.inventory_read.arn,
          aws_dynamodb_table.event_store.stream_arn
        ]
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

resource "aws_lambda_permission" "apigw_command" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.command_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.cqrs.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_query" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.cqrs.execution_arn}/*/*"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.prod.invoke_url
}

output "event_store_table" {
  value = aws_dynamodb_table.event_store.name
}
