terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {}

locals {
  tags = {
    ManagedBy   = "Terraform"
    Project     = "aws-security-lab-05"
    Environment = "lab"
  }
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "ec2-ssm-imdsv2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect = "Allow"
    principals { type = "Service" identifiers = ["ec2.amazonaws.com"] }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-imdsv2-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "egress_only" {
  name        = "egress-https-only"
  description = "Allow only HTTPS egress"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "egress-https-only" })
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_launch_template" "secure_lt" {
  name_prefix   = "secure-ec2-"
  image_id      = data.aws_ami.al2.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  metadata_options {
    http_tokens               = "required"
    http_endpoint             = "enabled"
    http_put_response_hop_limit = 2
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.egress_only.id]
    subnet_id                   = data.aws_subnet_ids.default.ids[0]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "secure-ec2" })
  }

  tags = local.tags
}

output "launch_template_id" { value = aws_launch_template.secure_lt.id }
output "instance_profile" { value = aws_iam_instance_profile.ssm_profile.name }
