terraform {
  required_version = ">= 1.5.0"
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

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_a_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "vpc_b_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "vpc_a_public_cidr" {
  type    = string
  default = "10.50.1.0/24"
}

variable "vpc_b_public_cidr" {
  type    = string
  default = "10.60.1.0/24"
}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Environment = "dev"
    Project     = "practice-peering"
  }
}

# VPC A
resource "aws_vpc" "a" {
  cidr_block           = var.vpc_a_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "vpc-a" })
}

resource "aws_subnet" "a_public" {
  vpc_id                  = aws_vpc.a.id
  cidr_block              = var.vpc_a_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags                    = merge(local.tags, { Name = "vpc-a-public" })
}

resource "aws_internet_gateway" "a" {
  vpc_id = aws_vpc.a.id
  tags   = merge(local.tags, { Name = "vpc-a-igw" })
}

resource "aws_route_table" "a_public" {
  vpc_id = aws_vpc.a.id
  tags   = merge(local.tags, { Name = "vpc-a-rt" })
}

resource "aws_route_table_association" "a_public" {
  subnet_id      = aws_subnet.a_public.id
  route_table_id = aws_route_table.a_public.id
}

# VPC B
resource "aws_vpc" "b" {
  cidr_block           = var.vpc_b_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "vpc-b" })
}

resource "aws_subnet" "b_public" {
  vpc_id                  = aws_vpc.b.id
  cidr_block              = var.vpc_b_public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b"
  tags                    = merge(local.tags, { Name = "vpc-b-public" })
}

resource "aws_internet_gateway" "b" {
  vpc_id = aws_vpc.b.id
  tags   = merge(local.tags, { Name = "vpc-b-igw" })
}

resource "aws_route_table" "b_public" {
  vpc_id = aws_vpc.b.id
  tags   = merge(local.tags, { Name = "vpc-b-rt" })
}

resource "aws_route_table_association" "b_public" {
  subnet_id      = aws_subnet.b_public.id
  route_table_id = aws_route_table.b_public.id
}

# Peering connection
resource "aws_vpc_peering_connection" "ab" {
  vpc_id      = aws_vpc.a.id
  peer_vpc_id = aws_vpc.b.id
  auto_accept = true
  tags        = merge(local.tags, { Name = "vpc-a-to-b" })
}

resource "aws_route" "a_to_b" {
  route_table_id              = aws_route_table.a_public.id
  destination_cidr_block      = aws_vpc.b.cidr_block
  vpc_peering_connection_id   = aws_vpc_peering_connection.ab.id
}

resource "aws_route" "b_to_a" {
  route_table_id              = aws_route_table.b_public.id
  destination_cidr_block      = aws_vpc.a.cidr_block
  vpc_peering_connection_id   = aws_vpc_peering_connection.ab.id
}

output "vpc_a_id" { value = aws_vpc.a.id }
output "vpc_b_id" { value = aws_vpc.b.id }
output "peering_id" { value = aws_vpc_peering_connection.ab.id }
output "subnet_a_public_id" { value = aws_subnet.a_public.id }
output "subnet_b_public_id" { value = aws_subnet.b_public.id }
