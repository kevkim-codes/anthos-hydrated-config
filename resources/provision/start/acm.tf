module "acm-prod-primary" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  skip_gcloud_download = true

  project_id       = data.google_client_config.current.project
  cluster_name     = module.prod-primary.name
  location         = module.prod-primary.location
  cluster_endpoint = module.prod-primary.endpoint

  operator_path    = var.acm_operator_path
  sync_repo        = var.acm_repo_location
  sync_branch      = "master"
  policy_dir       = "."
}

# Insert Lines Here
