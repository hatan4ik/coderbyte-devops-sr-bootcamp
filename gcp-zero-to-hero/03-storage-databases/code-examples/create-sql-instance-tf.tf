# This file defines a Cloud SQL instance using Terraform.

# Configure the Google Cloud provider
provider "google" {
  project = "gcp-hero-lab-01" # Change to your project ID
  region  = "us-central1"
}

# Use the 'random' provider to generate a secure password
provider "random" {}

resource "random_password" "db_password" {
  length  = 16
  special = true
  # Do not use characters that can cause issues in connection strings
  override_special = "!#$%*()-_=+[]{}<>"
}

# Define the Cloud SQL PostgreSQL instance
resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-main-instance"
  database_version = "POSTGRES_13"
  region           = "us-central1"

  settings {
    # Use a small, cost-effective tier for the lab
    tier = "db-g1-small"
  }

  # IMPORTANT: For labs, we disable deletion protection.
  # In production, this should always be `true`.
  deletion_protection = false
}

# Create a database within the instance
resource "google_sql_database" "app_db" {
  name     = "app-db"
  instance = google_sql_database_instance.postgres_instance.name
}

# Create a user for the database
resource "google_sql_user" "app_user" {
  name     = "app-user"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.db_password.result
}

# --- Outputs ---

output "instance_connection_name" {
  value       = google_sql_database_instance.postgres_instance.connection_name
  description = "The connection name for the Cloud SQL instance, used by the Cloud SQL Auth Proxy."
}

output "database_user_password" {
  value       = random_password.db_password.result
  description = "The generated password for the 'app-user'."
  # Mark as sensitive to prevent it from being displayed in logs
  sensitive   = true
}
