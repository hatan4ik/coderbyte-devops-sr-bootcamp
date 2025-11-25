# TODO: Replace with real provider (aws / azurerm / etc.)
terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type        = string
  description = "Deployment environment, e.g. dev/stage/prod"
  default     = "dev"
}

# Example skeleton resource (cloud-agnostic placeholder)
# Replace with an actual provider/resource for real use.
locals {
  bucket_name = "example-${var.environment}-bucket"
}
