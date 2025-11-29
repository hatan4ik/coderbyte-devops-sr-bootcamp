variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment label"
  default     = "dev"
}

variable "service_name" {
  type        = string
  description = "Service/application name"
  default     = "devops-demo"
}

variable "owner" {
  type        = string
  description = "Owner/team tag"
  default     = "platform-team"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention"
  default     = 14
}
