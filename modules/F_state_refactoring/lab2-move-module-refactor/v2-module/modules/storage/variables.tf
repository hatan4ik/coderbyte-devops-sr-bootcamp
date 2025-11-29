variable "service_name" {
  type        = string
  description = "Service/application name"
}

variable "environment" {
  type        = string
  description = "Environment label"
}

variable "owner" {
  type        = string
  description = "Owner/team tag"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention"
  default     = 14
}
