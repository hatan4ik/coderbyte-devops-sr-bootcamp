# This file defines a Cloud Armor security policy using Terraform.
# NOTE: This configuration assumes you already have a Backend Service
# for an HTTP Load Balancer.

provider "google" {
  project = "gcp-hero-lab-01" # Change to your project ID
}

# --- Prerequisites ---
# We assume a backend service named 'my-web-backend' already exists.
# We use a data source to get a reference to it without managing it here.
data "google_compute_backend_service" "web_backend" {
  name = "my-web-backend" # Change this to your backend service name
}


# --- Cloud Armor Configuration ---

# 1. Define the Security Policy
resource "google_compute_security_policy" "ip_blacklist" {
  name        = "ip-blacklist-policy"
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
        # This is a test IP address range.
        # For a real test, you might temporarily put your own IP here.
        src_ip_ranges = ["192.0.2.1/32"]
      }
    }
    description = "Block test IP"
  }
}

# 2. Attach the Policy to the Backend Service
resource "google_compute_backend_service" "backend_with_policy" {
  # This doesn't create a new backend service. It modifies the existing one.
  # We use the name from the data source to target the correct service.
  name             = data.google_compute_backend_service.web_backend.name
  project          = data.google_compute_backend_service.web_backend.project
  security_policy  = google_compute_security_policy.ip_blacklist.self_link

  # We must re-specify all the properties of the backend service that
  # Terraform would otherwise try to clear. The data source helps us here.
  # Note: This is a simplification. A real-world scenario might require
  # more complex import and management of the backend service itself.
  protocol         = data.google_compute_backend_service.web_backend.protocol
  port_name        = data.google_compute_backend_service.web_backend.port_name
  load_balancing_scheme = data.google_compute_backend_service.web_backend.load_balancing_scheme
  timeout_sec      = data.google_compute_backend_service.web_backend.timeout_sec
  backend {
    group = data.google_compute_backend_service.web_backend.backend[0].group
  }
}
