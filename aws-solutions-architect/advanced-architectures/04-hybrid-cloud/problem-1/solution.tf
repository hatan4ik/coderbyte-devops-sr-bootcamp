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

# VPC for hybrid connectivity
resource "aws_vpc" "hybrid" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "hybrid-vpc"
  }
}

# Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.hybrid.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "hybrid-private-${count.index + 1}"
  }
}

# Virtual Private Gateway for Direct Connect
resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.hybrid.id

  tags = {
    Name = "hybrid-vgw"
  }
}

# Direct Connect Gateway
resource "aws_dx_gateway" "main" {
  name            = "hybrid-dx-gateway"
  amazon_side_asn = 64512
}

# Direct Connect Gateway Association
resource "aws_dx_gateway_association" "main" {
  dx_gateway_id         = aws_dx_gateway.main.id
  associated_gateway_id = aws_vpn_gateway.main.id

  allowed_prefixes = [
    "10.0.0.0/16"
  ]
}

# Customer Gateway for VPN backup
resource "aws_customer_gateway" "onprem" {
  bgp_asn    = 65000
  ip_address = var.onprem_public_ip
  type       = "ipsec.1"

  tags = {
    Name = "onprem-cgw"
  }
}

# VPN Connection (backup)
resource "aws_vpn_connection" "backup" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.onprem.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = "hybrid-vpn-backup"
  }
}

# Route 53 Resolver Endpoints for Hybrid DNS
resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "hybrid-inbound"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.resolver.id]

  dynamic "ip_address" {
    for_each = aws_subnet.private
    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = {
    Name = "hybrid-resolver-inbound"
  }
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name      = "hybrid-outbound"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.resolver.id]

  dynamic "ip_address" {
    for_each = aws_subnet.private
    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = {
    Name = "hybrid-resolver-outbound"
  }
}

# Resolver Rule for on-premises DNS
resource "aws_route53_resolver_rule" "onprem" {
  domain_name          = "onprem.local"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  target_ip {
    ip   = var.onprem_dns_ip_1
    port = 53
  }

  target_ip {
    ip   = var.onprem_dns_ip_2
    port = 53
  }

  tags = {
    Name = "onprem-dns-rule"
  }
}

resource "aws_route53_resolver_rule_association" "onprem" {
  resolver_rule_id = aws_route53_resolver_rule.onprem.id
  vpc_id           = aws_vpc.hybrid.id
}

# Security Group for Resolver
resource "aws_security_group" "resolver" {
  name        = "resolver-sg"
  description = "Security group for Route 53 Resolver"
  vpc_id      = aws_vpc.hybrid.id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "resolver-sg"
  }
}

# Storage Gateway for hybrid storage
resource "aws_storagegateway_gateway" "file" {
  gateway_name     = "hybrid-file-gateway"
  gateway_timezone = "GMT"
  gateway_type     = "FILE_S3"

  tags = {
    Name = "hybrid-file-gateway"
  }
}

# S3 bucket for Storage Gateway
resource "aws_s3_bucket" "gateway" {
  bucket = "hybrid-storage-gateway-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "Storage Gateway Bucket"
  }
}

resource "aws_s3_bucket_versioning" "gateway" {
  bucket = aws_s3_bucket.gateway.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Directory Service for AD integration
resource "aws_directory_service_directory" "ad_connector" {
  name     = "onprem.local"
  password = var.ad_password
  size     = "Small"
  type     = "ADConnector"

  connect_settings {
    customer_dns_ips  = [var.onprem_dns_ip_1, var.onprem_dns_ip_2]
    customer_username = var.ad_username
    subnet_ids        = aws_subnet.private[*].id
    vpc_id            = aws_vpc.hybrid.id
  }

  tags = {
    Name = "AD Connector"
  }
}

# CloudWatch for monitoring
resource "aws_cloudwatch_metric_alarm" "dx_connection" {
  alarm_name          = "direct-connect-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ConnectionState"
  namespace           = "AWS/DX"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Direct Connect connection is down"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ConnectionId = var.dx_connection_id
  }
}

resource "aws_cloudwatch_metric_alarm" "vpn_tunnel" {
  alarm_name          = "vpn-tunnel-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "VPN tunnel is down"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    VpnId = aws_vpn_connection.backup.id
  }
}

resource "aws_sns_topic" "alerts" {
  name = "hybrid-connectivity-alerts"

  tags = {
    Name = "Hybrid Connectivity Alerts"
  }
}

# Transit Gateway for Outposts connectivity
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway for hybrid connectivity"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "hybrid-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hybrid" {
  subnet_ids         = aws_subnet.private[*].id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.hybrid.id

  tags = {
    Name = "hybrid-vpc-attachment"
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Variables
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "onprem_public_ip" {
  type        = string
  description = "Public IP of on-premises VPN endpoint"
}

variable "onprem_dns_ip_1" {
  type        = string
  description = "On-premises DNS server 1"
}

variable "onprem_dns_ip_2" {
  type        = string
  description = "On-premises DNS server 2"
}

variable "ad_username" {
  type        = string
  description = "AD service account username"
}

variable "ad_password" {
  type        = string
  sensitive   = true
  description = "AD service account password"
}

variable "dx_connection_id" {
  type        = string
  description = "Direct Connect connection ID"
}

# Outputs
output "vpc_id" {
  value = aws_vpc.hybrid.id
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.main.id
}

output "dx_gateway_id" {
  value = aws_dx_gateway.main.id
}

output "resolver_inbound_ips" {
  value = aws_route53_resolver_endpoint.inbound.ip_address[*].ip
}

output "storage_gateway_arn" {
  value = aws_storagegateway_gateway.file.arn
}
