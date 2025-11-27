# This file defines a GCE VM using Terraform.

# Configure the Google Cloud provider
provider "google" {
  # Your GCP project ID
  project = "gcp-hero-lab-01"
  # The region for the resources
  region  = "us-central1"
}

# Find the latest Debian 11 image
data "google_compute_image" "debian_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

# Define the GCE virtual machine
resource "google_compute_instance" "web_server_tf" {
  name         = "web-server-tf-01"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  # Use the Debian image found above
  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  # Configure the network interface
  network_interface {
    # Use the default VPC network
    network = "default"

    # Assign an external IP address
    access_config {
    }
  }

  # Assign a network tag to apply our firewall rule
  tags = ["http-server"]

  # Install Apache using a startup script
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    cat <<'EOT' > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
      <title>Welcome to Terraform on GCE!</title>
    </head>
    <body>
      <h1>Hello from a Terraform GCE Instance!</h1>
      <p>This VM was provisioned using Terraform.</p>
    </body>
    </html>
    EOT
  EOF

  # A description for the instance
  description = "A web server provisioned by Terraform."
}

# Output the external IP address of the VM
output "instance_ip" {
  value       = google_compute_instance.web_server_tf.network_interface[0].access_config[0].nat_ip
  description = "The external IP address of the GCE instance."
}
