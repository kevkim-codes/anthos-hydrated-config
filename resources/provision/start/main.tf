# Terraform configuration goes here

provider "google" {
  # Set variables?
  project = var.project_id
  region  = var.default_region
  #zone    = var.default_zone
}
# Query Terraform service account from GCP
data "google_client_config" "current" {}

output "project" {
  value = data.google_client_config.current.project
}


