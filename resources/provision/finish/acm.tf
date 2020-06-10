module "acm-prod-primary" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  skip_gcloud_download = true

  project_id       = data.google_client_config.current.project
  cluster_name     = google_container_cluster.prod-primary.name
  location         = google_container_cluster.prod-primary.location
  cluster_endpoint = google_container_cluster.prod-primary.endpoint

  operator_path    = var.acm_operator_path
  sync_repo        = var.acm_repo_location
  sync_branch      = "master"
  policy_dir       = "."
 
}

module "acm-prod-secondary" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  skip_gcloud_download = true

  project_id       = data.google_client_config.current.project
  cluster_name     = google_container_cluster.prod-secondary.name
  location         = google_container_cluster.prod-secondary.location
  cluster_endpoint = google_container_cluster.prod-secondary.endpoint

  operator_path    = var.acm_operator_path
  sync_repo        = var.acm_repo_location
  sync_branch      = "master"
  policy_dir       = "."
 
}

#Enable Anthos Configuration Management
module "acm-stage" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  skip_gcloud_download = true

  project_id       = data.google_client_config.current.project
  cluster_name     = google_container_cluster.stage.name
  location         = google_container_cluster.stage.location
  cluster_endpoint = google_container_cluster.stage.endpoint

  operator_path    = var.acm_operator_path
  sync_repo        = var.acm_repo_location
  sync_branch      = "master"
  policy_dir       = "."
}

