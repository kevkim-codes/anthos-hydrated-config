module "acm-prod-primary" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  skip_gcloud_download = true

  project_id       = data.google_client_config.current.project
  cluster_name     = google_container_cluster.prod-primary.name
  location         = google_container_cluster.prod-primary.location
  cluster_endpoint = google_container_cluster.prod-primary.endpoint

  sync_repo        = "https://github.com/cgrant/cluster_config"
  sync_branch      = "master"
  policy_dir       = "sample"

 
}

