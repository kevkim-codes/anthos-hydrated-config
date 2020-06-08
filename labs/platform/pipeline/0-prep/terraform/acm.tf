module "acm-prod" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"

  project_id       = data.google_client_config.current.project
  cluster_name     = google_container_cluster.prod.name
  location         = google_container_cluster.prod.location
  cluster_endpoint = google_container_cluster.prod.endpoint

  sync_repo        = "https://github.com/cgrant/cluster_config"
  sync_branch      = "master"
  policy_dir       = "sample"
skip_gcloud_download = true
  #sync_repo        = "https://github.com/GoogleCloudPlatform/csp-config-management.git"
  #sync_repo        = "git@github.com:GoogleCloudPlatform/csp-config-management.git"
  #sync_branch      = "1.0.0"
  #policy_dir       = "foo-corp"

 
}
# output "git_creds_public_prod" {
#   description = "Public key of SSH keypair to allow the Anthos Operator to authenticate to your Git repository."
#   value       = module.acm-prod.git_creds_public
# }

# module "acm-stage" {
#    source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"

#    project_id       = data.google_client_config.current.project
#    cluster_name     = google_container_cluster.stage.name
#    location         = google_container_cluster.stage.location
#    cluster_endpoint = google_container_cluster.stage.endpoint
# skip_gcloud_download = true
#    sync_repo        = "https://github.com/cgrant/cluster_config"
#    sync_branch      = "stage"
#    policy_dir       = "sample"

# }

# output "git_creds_public_stage" {
#   description = "Public key of SSH keypair to allow the Anthos Operator to authenticate to your Git repository."
#   value       = module.acm-stage.git_creds_public
# }