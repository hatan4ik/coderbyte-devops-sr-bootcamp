# This file defines a custom VPC, subnets, and firewall rules with Terraform.

provider "google" {
  project = "gcp-hero-lab-01" # Change to your project ID
}

# 1. VPC Configuration
resource "google_compute_network" "custom_vpc" {
  name                    = "my-custom-vpc"
  auto_create_subnetworks = false
  description             = "A custom VPC created with Terraform."
}

# 2. Subnet Configuration
resource "google_compute_subnetwork" "subnet_us" {
  name          = "subnet-us-central1"
  ip_cidr_range = "10.10.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.custom_vpc.self_link
}

resource "google_compute_subnetwork" "subnet_eu" {
  name          = "subnet-europe-west1"
  ip_cidr_range = "10.20.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.custom_vpc.self_link
}

# 3. Firewall Rule Configuration
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-ssh-icmp"
  network = google_compute_network.custom_vpc.name

  # Allow traffic from our defined subnets
  source_ranges = [
    google_compute_subnetwork.subnet_us.ip_cidr_range,
    google_compute_subnetwork.subnet_eu.ip_cidr_range
  ]

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
