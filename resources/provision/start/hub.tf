module "hub-prod-primary" {
  source           = "github.com/cgrant/terraform-google-kubernetes-engine//modules/hub?ref=hub-submodule"
  project_id       = data.google_client_config.current.project
  cluster_name     = module.prod-primary.name
  location         = module.prod-primary.location
  cluster_endpoint = module.prod-primary.endpoint

  gke_hub_sa_name  = module.prod-primary.name 
  gke_hub_membership_name = module.prod-primary.name

}