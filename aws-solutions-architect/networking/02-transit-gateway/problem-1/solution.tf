terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Multi-region providers
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west_1"
  region = "eu-west-1"
}

# Transit Gateway - US East 1
resource "aws_ec2_transit_gateway" "us_east" {
  provider                        = aws.us_east_1
  description                     = "TGW Hub US East 1"
  amazon_side_asn                 = 64512
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support               = "enable"

  tags = {
    Name        = "tgw-us-east-1-hub"
    Environment = "shared"
  }
}

# Transit Gateway - EU West 1
resource "aws_ec2_transit_gateway" "eu_west" {
  provider                        = aws.eu_west_1
  description                     = "TGW Hub EU West 1"
  amazon_side_asn                 = 64513
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support               = "enable"

  tags = {
    Name        = "tgw-eu-west-1-hub"
    Environment = "shared"
  }
}

# TGW Peering - US to EU
resource "aws_ec2_transit_gateway_peering_attachment" "us_to_eu" {
  provider                = aws.us_east_1
  peer_region             = "eu-west-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.eu_west.id
  transit_gateway_id      = aws_ec2_transit_gateway.us_east.id

  tags = {
    Name = "tgw-peering-us-eu"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "eu_accept" {
  provider                      = aws.eu_west_1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.us_to_eu.id

  tags = {
    Name = "tgw-peering-us-eu-accept"
  }
}

# Route Tables - Environment Isolation
resource "aws_ec2_transit_gateway_route_table" "prod_us" {
  provider           = aws.us_east_1
  transit_gateway_id = aws_ec2_transit_gateway.us_east.id

  tags = {
    Name        = "tgw-rt-prod-us"
    Environment = "prod"
  }
}

resource "aws_ec2_transit_gateway_route_table" "dev_us" {
  provider           = aws.us_east_1
  transit_gateway_id = aws_ec2_transit_gateway.us_east.id

  tags = {
    Name        = "tgw-rt-dev-us"
    Environment = "dev"
  }
}

resource "aws_ec2_transit_gateway_route_table" "inspection_us" {
  provider           = aws.us_east_1
  transit_gateway_id = aws_ec2_transit_gateway.us_east.id

  tags = {
    Name        = "tgw-rt-inspection-us"
    Environment = "shared"
  }
}

# VPCs - Production
resource "aws_vpc" "prod_us" {
  provider             = aws.us_east_1
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-prod-us-east-1"
    Environment = "prod"
  }
}

# VPCs - Development
resource "aws_vpc" "dev_us" {
  provider             = aws.us_east_1
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-dev-us-east-1"
    Environment = "dev"
  }
}

# VPCs - Inspection (Centralized Egress)
resource "aws_vpc" "inspection_us" {
  provider             = aws.us_east_1
  cidr_block           = "10.255.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-inspection-us-east-1"
    Environment = "shared"
  }
}

# Subnets for Inspection VPC
resource "aws_subnet" "inspection_public" {
  provider          = aws.us_east_1
  vpc_id            = aws_vpc.inspection_us.id
  cidr_block        = "10.255.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-inspection-public-1a"
  }
}

resource "aws_subnet" "inspection_tgw" {
  provider          = aws.us_east_1
  vpc_id            = aws_vpc.inspection_us.id
  cidr_block        = "10.255.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-inspection-tgw-1a"
  }
}

# Internet Gateway for Inspection VPC
resource "aws_internet_gateway" "inspection" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.inspection_us.id

  tags = {
    Name = "igw-inspection"
  }
}

# NAT Gateway for centralized egress
resource "aws_eip" "nat" {
  provider = aws.us_east_1
  domain   = "vpc"

  tags = {
    Name = "eip-nat-inspection"
  }
}

resource "aws_nat_gateway" "inspection" {
  provider      = aws.us_east_1
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.inspection_public.id

  tags = {
    Name = "nat-inspection"
  }
}

# TGW Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "prod_us" {
  provider           = aws.us_east_1
  subnet_ids         = [aws_subnet.prod_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.us_east.id
  vpc_id             = aws_vpc.prod_us.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name        = "tgw-attach-prod-us"
    Environment = "prod"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dev_us" {
  provider           = aws.us_east_1
  subnet_ids         = [aws_subnet.dev_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.us_east.id
  vpc_id             = aws_vpc.dev_us.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name        = "tgw-attach-dev-us"
    Environment = "dev"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_us" {
  provider           = aws.us_east_1
  subnet_ids         = [aws_subnet.inspection_tgw.id]
  transit_gateway_id = aws_ec2_transit_gateway.us_east.id
  vpc_id             = aws_vpc.inspection_us.id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name        = "tgw-attach-inspection-us"
    Environment = "shared"
  }
}

# TGW subnets
resource "aws_subnet" "prod_tgw" {
  provider          = aws.us_east_1
  vpc_id            = aws_vpc.prod_us.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-prod-tgw-1a"
  }
}

resource "aws_subnet" "dev_tgw" {
  provider          = aws.us_east_1
  vpc_id            = aws_vpc.dev_us.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-dev-tgw-1a"
  }
}

# Route Table Associations
resource "aws_ec2_transit_gateway_route_table_association" "prod_us" {
  provider                       = aws.us_east_1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_us.id
}

resource "aws_ec2_transit_gateway_route_table_association" "dev_us" {
  provider                       = aws.us_east_1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev_us.id
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection_us" {
  provider                       = aws.us_east_1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_us.id
}

# Routes - Default route to inspection VPC
resource "aws_ec2_transit_gateway_route" "prod_default" {
  provider                       = aws.us_east_1
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_us.id
}

resource "aws_ec2_transit_gateway_route" "dev_default" {
  provider                       = aws.us_east_1
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev_us.id
}

# Cross-region routes
resource "aws_ec2_transit_gateway_route" "prod_to_eu" {
  provider                       = aws.us_east_1
  destination_cidr_block         = "10.10.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.us_to_eu.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod_us.id
}

# VPN Connection to On-Premises
resource "aws_customer_gateway" "onprem" {
  provider   = aws.us_east_1
  bgp_asn    = 65000
  ip_address = "203.0.113.1"
  type       = "ipsec.1"

  tags = {
    Name = "cgw-onprem"
  }
}

resource "aws_vpn_connection" "onprem" {
  provider            = aws.us_east_1
  customer_gateway_id = aws_customer_gateway.onprem.id
  transit_gateway_id  = aws_ec2_transit_gateway.us_east.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = "vpn-onprem"
  }
}

# Flow Logs
resource "aws_flow_log" "tgw_us" {
  provider             = aws.us_east_1
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  transit_gateway_id   = aws_ec2_transit_gateway.us_east.id

  tags = {
    Name = "flow-log-tgw-us"
  }
}

resource "aws_s3_bucket" "flow_logs" {
  provider      = aws.us_east_1
  bucket        = "tgw-flow-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  provider = aws.us_east_1
  bucket   = aws_s3_bucket.flow_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

data "aws_caller_identity" "current" {
  provider = aws.us_east_1
}

# Outputs
output "tgw_us_id" {
  value = aws_ec2_transit_gateway.us_east.id
}

output "tgw_eu_id" {
  value = aws_ec2_transit_gateway.eu_west.id
}

output "vpn_connection_id" {
  value = aws_vpn_connection.onprem.id
}

output "flow_logs_bucket" {
  value = aws_s3_bucket.flow_logs.bucket
}
