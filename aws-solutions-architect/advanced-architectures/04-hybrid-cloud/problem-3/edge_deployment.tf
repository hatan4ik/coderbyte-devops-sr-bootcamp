terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

# Regional VPC
provider "aws" {
  alias  = "region"
  region = "us-east-1"
}

# Wavelength Zone
provider "aws" {
  alias  = "wavelength"
  region = "us-east-1"
}

# VPC with Wavelength support
resource "aws_vpc" "main" {
  provider             = aws.region
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Regional subnet
resource "aws_subnet" "regional" {
  provider          = aws.region
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Wavelength subnet
resource "aws_subnet" "wavelength" {
  provider          = aws.wavelength
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1-wl1-bos-wlz-1"
}

# Carrier Gateway for Wavelength
resource "aws_ec2_carrier_gateway" "main" {
  provider = aws.wavelength
  vpc_id   = aws_vpc.main.id
}

# Route table for Wavelength
resource "aws_route_table" "wavelength" {
  provider = aws.wavelength
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block         = "0.0.0.0/0"
    carrier_gateway_id = aws_ec2_carrier_gateway.main.id
  }
}

resource "aws_route_table_association" "wavelength" {
  provider       = aws.wavelength
  subnet_id      = aws_subnet.wavelength.id
  route_table_id = aws_route_table.wavelength.id
}

# EC2 instance in Wavelength Zone
resource "aws_instance" "edge_app" {
  provider               = aws.wavelength
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.wavelength.id
  vpc_security_group_ids = [aws_security_group.edge.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              docker run -d -p 80:8080 edge-app:latest
              EOF

  tags = {
    Name = "wavelength-edge-app"
  }
}

# Security group for edge instances
resource "aws_security_group" "edge" {
  provider = aws.wavelength
  vpc_id   = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DynamoDB for edge data
resource "aws_dynamodb_table" "edge_data" {
  provider       = aws.region
  name           = "edge-data"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "deviceId"
  range_key      = "timestamp"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "deviceId"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name            = "LocationIndex"
    hash_key        = "location"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  attribute {
    name = "location"
    type = "S"
  }
}

# Lambda@Edge for content delivery
resource "aws_lambda_function" "edge_function" {
  provider      = aws.region
  filename      = "edge_function.zip"
  function_name = "edge-content-processor"
  role          = aws_iam_role.lambda_edge.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  publish       = true
  timeout       = 5
  memory_size   = 128
}

resource "aws_iam_role" "lambda_edge" {
  provider = aws.region
  name     = "lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

# CloudFront distribution with Lambda@Edge
resource "aws_cloudfront_distribution" "edge_cdn" {
  provider = aws.region
  enabled  = true

  origin {
    domain_name = aws_instance.edge_app.private_ip
    origin_id   = "wavelength-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "wavelength-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.edge_function.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# CloudWatch metrics for edge monitoring
resource "aws_cloudwatch_metric_alarm" "edge_latency" {
  provider            = aws.region
  alarm_name          = "edge-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Edge function latency > 10ms"

  dimensions = {
    FunctionName = aws_lambda_function.edge_function.function_name
  }
}

data "aws_ami" "amazon_linux" {
  provider    = aws.wavelength
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

output "wavelength_instance_ip" {
  value = aws_instance.edge_app.private_ip
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.edge_cdn.domain_name
}
