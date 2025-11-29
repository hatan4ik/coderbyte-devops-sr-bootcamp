# This file defines a custom VPC, subnets, and firewall rules with Terraform.

provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Input Variables ---
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The primary GCP region for resources."
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "The name of the custom VPC."
  type        = string
  default     = "my-custom-vpc"
}

variable "subnets" {
  description = "A map of subnets to create, with their regions and IP CIDR ranges."
  type = map(object({
    region        = string
    ip_cidr_range = string
  }))
  default = {
    "us-central1" = {
      region        = "us-central1"
      ip_cidr_range = "10.10.1.0/24"
    },
    "europe-west1" = {
      region        = "europe-west1"
      ip_cidr_range = "10.20.1.0/24"
    }
  }
}

# 1. VPC Configuration
resource "google_compute_network" "custom_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "A custom VPC created with Terraform."
}

# 3. Firewall Rule Configuration
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-ssh-icmp"
  network = google_compute_network.custom_vpc.name

  # Allow traffic from our defined subnets
  source_ranges = [for s in google_compute_subnetwork.subnets : s.ip_cidr_range]

  # Apply to VMs with this tag
  target_tags = ["internal-vm"]

  # Allow SSH (tcp:22) and ICMP (for ping)
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "icmp"
  }

  description = "Allows SSH and ICMP traffic between internal subnets."
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-external-health-check"
  network = google_compute_network.custom_vpc.name

  # Allow traffic from Google's health checkers
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  # Apply to VMs with this tag
  target_tags = ["web-server"]

  # Allow HTTP (tcp:80)
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  description = "Allows health checks from Google Load Balancers."
}

output "vpc_name" {
  value       = google_compute_network.custom_vpc.name
  description = "The name of the custom VPC."
}

# --- Dynamic Subnet Creation ---
resource "google_compute_subnetwork" "subnets" {
  for_each      = var.subnets
  name          = "subnet-${each.key}"
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.custom_vpc.self_link
}
