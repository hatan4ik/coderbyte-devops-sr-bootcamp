variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_a_cidr" {
  description = "CIDR for VPC A"
  type        = string
  default     = "10.10.0.0/16"
}

variable "vpc_b_cidr" {
  description = "CIDR for VPC B"
  type        = string
  default     = "10.20.0.0/16"
}

variable "vpc_a_public_cidr" {
  description = "CIDR for VPC A public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "vpc_b_public_cidr" {
  description = "CIDR for VPC B public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "az_a" {
  description = "Availability Zone for VPC A"
  type        = string
  default     = "us-east-1a"
}

variable "az_b" {
  description = "Availability Zone for VPC B"
  type        = string
  default     = "us-east-1b"
}

variable "trusted_cidr" {
  description = "CIDR allowed to reach instances"
  type        = string
  default     = "10.0.0.0/8"
}
