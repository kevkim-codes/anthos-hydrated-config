
module "acm-stage" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  skip_gcloud_download = true

  project_id       = data.google_client_config.current.project
  cluster_name     = google_container_cluster.stage.name
  location         = google_container_cluster.stage.location
  cluster_endpoint = google_container_cluster.stage.endpoint

  sync_repo        = "https://github.com/cgrant/cluster_config"
  sync_branch      = "stage"
  policy_dir       = "sample"

}

# output "git_creds_public_stage" {
#   description = "Public key of SSH keypair to allow the Anthos Operator to authenticate to your Git repository."
#   value       = module.acm-stage.git_creds_public
# }