# This file defines a Cloud Armor security policy using Terraform.
# NOTE: This configuration assumes you already have a Backend Service
# for an HTTP Load Balancer.

provider "google" {
  project = var.project_id
}

# --- Input Variables ---
variable "project_id" {
  description = "The GCP project ID where the resources exist."
  type        = string
}

variable "backend_service_name" {
  description = "The name of the backend service to attach the policy to."
  type        = string
}

variable "blocked_ip_ranges" {
  description = "A list of IP ranges (CIDR) to block."
  type        = list(string)
  default     = ["192.0.2.1/32"] # Example test IP
}

# --- Prerequisites ---
# We assume a backend service named 'my-web-backend' already exists.
# We use a data source to get a reference to it without managing it here.
data "google_compute_backend_service" "web_backend" {
  name    = var.backend_service_name
  project = var.project_id
}


# --- Cloud Armor Configuration ---

# 1. Define the Security Policy
resource "google_compute_security_policy" "ip_blacklist" {
  name        = "${var.backend_service_name}-blacklist-policy"
  description = "Policy to block specific IP addresses."

  # Default rule to allow traffic that doesn't match any other rule.
  # Priority is the lowest possible value.
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow all"
  }

  # Rule to block a specific IP address.
  # This has a higher priority (lower number) than the default rule.
  rule {
    action   = "deny(403)" # Respond with a 403 Forbidden error
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        # This list of IPs is now managed by a variable.
        src_ip_ranges = var.blocked_ip_ranges
      }
    }
    description = "Block test IP"
  }
}

# 2. Attach the Policy to the Backend Service
resource "google_compute_backend_service_security_policy" "policy_attachment" {
  project         = data.google_compute_backend_service.web_backend.project
  backend_service = data.google_compute_backend_service.web_backend.name
  security_policy = google_compute_security_policy.ip_blacklist.self_link
}

# Note: The previous method of attaching a policy by re-declaring the backend service is fragile.
# The `google_compute_backend_service_security_policy` resource is the modern, recommended approach
# as it manages only the attachment, preventing conflicts with other configurations.
