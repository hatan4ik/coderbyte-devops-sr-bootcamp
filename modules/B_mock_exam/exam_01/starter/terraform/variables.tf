variable "bucket_base_name" {
  type        = string
  description = "Base name for the S3 bucket. A random suffix will be added."
}

variable "environment" {
  type        = string
  description = "Deployment environment, e.g. dev/stage/prod"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the bucket."
  default     = {}
}

variable "enable_versioning" {
  type        = bool
  description = "If true, versioning will be enabled on the bucket."
  default     = true
}

variable "block_public_access" {
  type        = bool
  description = "If true, all public access to the bucket will be blocked."
  default     = true
}

variable "sse_algorithm" {
  type        = string
  description = "The server-side encryption algorithm to use. For example, AES256 or aws:kms."
  default     = "AES256"
}