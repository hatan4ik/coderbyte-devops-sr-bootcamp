terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "my-firewall-rule-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Use a target tag to apply this rule only to specific VMs
  target_tags = ["ssh-allowed"]

  # For production, you should restrict this to specific IP ranges
  source_ranges = ["0.0.0.0/0"]

  description = "Allow SSH access from anywhere"
}
