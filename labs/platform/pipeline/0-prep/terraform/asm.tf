module "asm" {
  source           = "./modules/asm"
  cluster_name     = google_container_cluster.prod.name
  cluster_endpoint = google_container_cluster.prod.endpoint
  project_id       = data.google_client_config.current.project
  location         = google_container_cluster.prod.location

}