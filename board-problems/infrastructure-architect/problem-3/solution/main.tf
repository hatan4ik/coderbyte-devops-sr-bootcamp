variable "region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "multi-region-app"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.name}-db"
  engine     = "postgres"
  instance_class = "db.t3.medium"
  allocated_storage = 20
  username   = "appuser"
  password   = "ChangeMe123!"
  multi_az   = true
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_ids = module.vpc.private_subnets
  backup_window = "03:00-04:00"
}

resource "aws_security_group" "db" {
  name   = "${var.name}-db-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
