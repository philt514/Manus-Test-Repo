terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Provider
provider "google" {
  project = var.project_id
  region  = var.region
  # Credentials are set via GOOGLE_APPLICATION_CREDENTIALS environment variable
}

# Cloud SQL Instance
resource "google_sql_database_instance" "default" {
  database_version = "POSTGRES_14"
  project          = var.project_id
  region           = var.region
  settings {
    tier = "db-f1-micro" # Smallest tier for cost-effectiveness
    disk_size = 10
    disk_type = "PD_SSD"
    backup_configuration {
      enabled            = true

    }
    ip_configuration {
      ipv4_enabled = true
      # Allow all IPs for simplicity in this example, but in production, restrict this
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }
  deletion_protection  = false
  name                 = "manus-cloudsql-instance"
}

# Database
resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
  project  = var.project_id
}

# User
resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  project  = var.project_id
  password = var.db_password
}

# Output the connection details
output "instance_connection_name" {
  value = google_sql_database_instance.default.connection_name
}

output "public_ip_address" {
  value = google_sql_database_instance.default.public_ip_address
}

output "database_name" {
  value = google_sql_database.database.name
}

output "database_user" {
  value = google_sql_user.user.name
}

output "database_password" {
  value     = google_sql_user.user.password
  sensitive = true
}
