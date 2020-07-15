module "acm-prod-primary" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm?ref=fix-gcloud-install"
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
