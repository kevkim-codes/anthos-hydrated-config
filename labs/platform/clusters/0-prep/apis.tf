
# Enable APIs
resource "google_project_service" "compute" {
  project = data.google_client_config.current.project
  service = "compute.googleapis.com"

  disable_on_destroy  = false
  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_project_service" "container" {
  project = data.google_client_config.current.project
  service = "container.googleapis.com"

  disable_on_destroy  = false
}

resource "google_project_service" "cloudresourcemanager" {
  project = data.google_client_config.current.project
  service = "cloudresourcemanager.googleapis.com"

  disable_on_destroy  = false
}

# Enable APIs
resource "google_project_service" "anthos" {
  project = data.google_client_config.current.project
  service = "anthos.googleapis.com"

  disable_on_destroy  = false
  depends_on = [google_project_service.cloudresourcemanager]
}