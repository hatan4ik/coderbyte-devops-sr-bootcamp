# This file defines a Cloud SQL instance using Terraform.

# Configure the Google Cloud provider
provider "google" {
  project = "gcp-hero-lab-01" # Change to your project ID
  region  = "us-central1"
  project = var.project_id
  region  = var.region
}

# --- Input Variables ---
variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud SQL instance."
  type        = string
  default     = "us-central1" # Default for labs, but should be explicit in production
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'staging', or 'prod'."
  }
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
resource "google_sql_database_instance" "main_instance" {
  name             = "postgres-${var.environment}-instance"
  database_version = "POSTGRES_13" # Consider making this a variable
  region           = var.region
  database_version = "POSTGRES_13" # Example: Use a specific version

  settings {
    # Use a small, cost-effective tier for the lab
    tier = "db-g1-small"
    # Production-grade tier (example, adjust based on workload)
    tier = var.instance_tier
    disk_size = var.disk_size_gb
    disk_type = "SSD" # SSD is generally recommended for performance
    disk_autoresize = true # Enable storage auto-scaling

    # High Availability (HA) configuration for production
    # This creates a standby instance in a different zone for automatic failover.
    availability_type = var.environment == "prod" ? "REGIONAL" : "ZONAL"

    # Automated backups and point-in-time recovery
    backup_configuration {
      enabled            = true
      start_time         = "03:00" # Example: Off-peak hours
      binary_log_enabled = true    # Required for point-in-time recovery
      location           = var.region # Backup location
      transaction_log_retention_days = 7 # Retain logs for 7 days for PITR
    }

    # IP Configuration: Prefer Private IP for security
    ip_configuration {
      ipv4_enabled = false # Disable public IP by default
      private_network = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"

      # Authorized networks for specific access (e.g., jump boxes, CI/CD)
      # Only needed if ipv4_enabled is true, but good to show for completeness
      # authorized_networks {
      #   value = "10.0.0.0/24" # Example: CIDR of a jump box network
      #   name  = "Jumpbox Network"
      # }
    }

    # Maintenance window for controlled updates
    maintenance_window {
      day  = 7 # Sunday
      hour = 2 # 2 AM UTC
      update_period = "WEEKLY"
    }

    # Database flags for performance or security tuning (example)
    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }
  }

  # IMPORTANT: For labs, we disable deletion protection.
  # In production, this should always be `true`.
  deletion_protection = false
  # IMPORTANT: For production, this should always be `true`.
  deletion_protection = var.environment == "prod" ? true : false

  # Labels for cost allocation and resource management
  labels = {
    environment = var.environment
    application = "app-service"
    owner       = "devops-team"
    managed_by  = "terraform"
  }
}

# Create a database within the instance
resource "google_sql_database" "app_db" {
  name     = "app-db"
  instance = google_sql_database_instance.postgres_instance.name
  name     = "app_database" # Use a more descriptive name
  instance = google_sql_database_instance.main_instance.name
}

# Create a user for the database
resource "google_sql_user" "app_user" {
  name     = "app-user"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.db_password.result
  name     = "app_user" # Use a more descriptive name
  instance = google_sql_database_instance.main_instance.name
  # In production, the password should be stored in a secret manager.
  # This output is for demonstration; applications should retrieve from Secret Manager.
  password = random_password.db_password.result

  # Consider using IAM database authentication for production
  # type = "CLOUD_IAM_USER"
  # host = "%" # Or specific host
}

# --- Additional Variables for the above changes ---
variable "instance_tier" {
  description = "The machine type for the Cloud SQL instance (e.g., db-n1-standard-1)."
  type        = string
  default     = "db-g1-small" # Default for labs, but should be production-grade for 'prod' env
}

variable "disk_size_gb" {
  description = "The disk size for the Cloud SQL instance in GB."
  type        = number
  default     = 20 # Starting disk size
}

variable "vpc_network_name" {
  description = "The name of the VPC network to connect the Cloud SQL instance to via Private Service Access."
  type        = string
}

# --- Outputs ---

output "instance_connection_name" {
  value       = google_sql_database_instance.postgres_instance.connection_name
  value       = google_sql_database_instance.main_instance.connection_name
  description = "The connection name for the Cloud SQL instance, used by the Cloud SQL Auth Proxy."
}

output "database_user_password" {
  value       = random_password.db_password.result
  description = "The generated password for the 'app-user'."
  # Mark as sensitive to prevent it from being displayed in logs
  sensitive   = true
  sensitive   = true # Mark as sensitive to prevent it from being displayed in logs
}
