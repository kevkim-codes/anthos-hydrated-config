module "asm" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/asm"
  project_id       = data.google_client_config.current.project
  cluster_name     = module.stage.name
  location         = module.stage.location
  cluster_endpoint = module.stage.endpoint
  use_tf_google_credentials_env_var = false
}