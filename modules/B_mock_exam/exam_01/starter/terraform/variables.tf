variable "region" {
  type        = string
  description = "AWS region for the deployment."
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment, e.g., dev, staging, prod."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "The environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = "coderbyte-exam-01"
}

variable "bucket_base_name" {
  type        = string
  description = "Base name for the S3 bucket."
  default     = "app-data"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to resources."
  default     = {}
}
