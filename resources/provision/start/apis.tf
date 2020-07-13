


# Enable APIs

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "2.1.3"

  project_id  = data.google_client_config.current.project
  disable_services_on_destroy = false
  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "anthos.googleapis.com"

  ]
}