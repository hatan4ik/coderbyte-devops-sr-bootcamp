# Core variables with validation
variable "region" {
  type        = string
  description = "Primary AWS region"
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
    error_message = "Region must be valid AWS region format (e.g., us-east-1)."
  }
}

variable "dr_region" {
  type        = string
  description = "Disaster recovery region"
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}

variable "service_name" {
  type        = string
  description = "Service name (lowercase, alphanumeric, hyphens only)"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.service_name))
    error_message = "Service name must be 3-63 characters, lowercase alphanumeric and hyphens only."
  }
}

variable "owner" {
  type        = string
  description = "Team or individual owner"
  
  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner must be specified."
  }
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
  default     = "engineering"
}

variable "compliance_level" {
  type        = string
  description = "Compliance level (low, medium, high)"
  default     = "medium"

  validation {
    condition     = contains(["low", "medium", "high"], var.compliance_level)
    error_message = "Compliance level must be low, medium, or high."
  }
}

# Feature flags
variable "enable_versioning" {
  type        = bool
  description = "Enable S3 versioning"
  default     = true
}

variable "enable_replication" {
  type        = bool
  description = "Enable cross-region replication"
  default     = false
}

variable "enable_multi_region" {
  type        = bool
  description = "Enable multi-region KMS key"
  default     = false
}

# Security variables
variable "kms_key_admins" {
  type        = list(string)
  description = "List of IAM ARNs for KMS key administrators"
  default     = []
}

variable "permissions_boundary_arn" {
  type        = string
  description = "IAM permissions boundary ARN"
  default     = null
}

variable "allowed_source_ips" {
  type        = list(string)
  description = "Allowed source IP ranges for assume role"
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for ip in var.allowed_source_ips : can(cidrhost(ip, 0))])
    error_message = "All entries must be valid CIDR blocks."
  }
}

variable "assume_role_arn" {
  type        = string
  description = "IAM role ARN to assume for Terraform operations"
  default     = null
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : can(regex("^[a-zA-Z0-9_-]+$", k))])
    error_message = "Tag keys must contain only alphanumeric characters, underscores, and hyphens."
  }
}
