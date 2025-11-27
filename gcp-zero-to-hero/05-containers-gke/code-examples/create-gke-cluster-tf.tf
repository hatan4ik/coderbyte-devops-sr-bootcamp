# This file defines a GKE cluster and a custom node pool using Terraform.

provider "google" {
  project = "gcp-hero-lab-01" # Change to your project ID
}

# Define the GKE cluster (control plane)
resource "google_container_cluster" "primary" {
  name     = "primary-gke-cluster"
  location = "us-central1-a"

  # We can't create a cluster with no node pool, so we create a minimal one
  # and then remove it later.
  initial_node_count = 1
  remove_default_node_pool = true

  deletion_protection = false
}

# Define a custom node pool for our workloads
resource "google_container_node_pool" "primary_nodes" {
  name       = "general-purpose-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    # A cost-effective machine type for general workloads
    machine_type = "e2-medium"

    # Define the OAuth scopes to allow access to other GCP services
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Add labels and tags if needed
    labels = {
      "workload-type" = "general"
    }
    tags = ["gke-node"]
  }

  # Ensure this node pool is only created after the cluster is ready
  depends_on = [google_container_cluster.primary]
}


# --- Outputs ---

output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "The name of the GKE cluster."
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "The IP address of the GKE cluster control plane."
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${google_container_cluster.primary.location}"
  description = "Command to configure kubectl for this cluster."
}
