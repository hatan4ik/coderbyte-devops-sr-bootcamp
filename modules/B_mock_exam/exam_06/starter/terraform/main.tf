terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################
# VPC A
############################
resource "aws_vpc" "a" {
  cidr_block           = var.vpc_a_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-a"
  }
}

resource "aws_subnet" "a_public" {
  vpc_id                  = aws_vpc.a.id
  cidr_block              = var.vpc_a_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az_a
  tags = { Name = "vpc-a-public" }
}

resource "aws_internet_gateway" "a" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "vpc-a-igw" }
}

resource "aws_route_table" "a_public" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "vpc-a-public-rt" }
}

resource "aws_route_table_association" "a_public" {
  subnet_id      = aws_subnet.a_public.id
  route_table_id = aws_route_table.a_public.id
}

############################
# VPC B
############################
resource "aws_vpc" "b" {
  cidr_block           = var.vpc_b_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-b"
  }
}

resource "aws_subnet" "b_public" {
  vpc_id                  = aws_vpc.b.id
  cidr_block              = var.vpc_b_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az_b
  tags = { Name = "vpc-b-public" }
}

resource "aws_internet_gateway" "b" {
  vpc_id = aws_vpc.b.id
  tags   = { Name = "vpc-b-igw" }
}

resource "aws_route_table" "b_public" {
  vpc_id = aws_vpc.b.id
  tags   = { Name = "vpc-b-public-rt" }
}

resource "aws_route_table_association" "b_public" {
  subnet_id      = aws_subnet.b_public.id
  route_table_id = aws_route_table.b_public.id
}

############################
# Peering
############################
resource "aws_vpc_peering_connection" "ab" {
  vpc_id      = aws_vpc.a.id
  peer_vpc_id = aws_vpc.b.id
  auto_accept = true

  tags = { Name = "a-to-b" }
}

resource "aws_route" "a_to_b" {
  route_table_id         = aws_route_table.a_public.id
  destination_cidr_block = aws_vpc.b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ab.id
}

resource "aws_route" "b_to_a" {
  route_table_id         = aws_route_table.b_public.id
  destination_cidr_block = aws_vpc.a.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.ab.id
}

############################
# Security groups for testing
############################
resource "aws_security_group" "a_public" {
  name        = "vpc-a-public-sg"
  description = "Allow SSH/ICMP from trusted CIDR"
  vpc_id      = aws_vpc.a.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.trusted_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.trusted_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "b_public" {
  name        = "vpc-b-public-sg"
  description = "Allow SSH/ICMP from trusted CIDR"
  vpc_id      = aws_vpc.b.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.trusted_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.trusted_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# Outputs
############################
output "vpc_a_id" { value = aws_vpc.a.id }
output "vpc_b_id" { value = aws_vpc.b.id }
output "vpc_peering_id" { value = aws_vpc_peering_connection.ab.id }
output "subnet_a_public_id" { value = aws_subnet.a_public.id }
output "subnet_b_public_id" { value = aws_subnet.b_public.id }
output "route_table_a_public" { value = aws_route_table.a_public.id }
output "route_table_b_public" { value = aws_route_table.b_public.id }
