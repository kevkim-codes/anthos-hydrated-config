 data "google_project" "project" {
  project_id = var.project_id
}

# Cluster
module "prod-primary" {
  name                    = "${var.gke_name}-prod-primary"
  project_id              = module.project-services.project_id
  source                  = "terraform-google-modules/kubernetes-engine/google"
  regional                = false
  region                  = var.default_region
  network                 = var.network
  subnetwork              = var.subnetwork
  ip_range_pods           = var.ip_range_pods
  ip_range_services       = var.ip_range_services
  zones                   = var.default_zone
  #release_channel         = "RAPID"
  node_pools = [
    {
      name         = "default-pool"
      autoscaling  = false
      auto_upgrade = true
      # ASM requires minimum 4 nodes and e2-standard-4
      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]

}
# Cluster Credentials
resource "null_resource" "configure_kubectl_prod_primary" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.prod-primary.name} --zone ${module.prod-primary.location} --project ${data.google_client_config.current.project}"
  }
  depends_on = [module.prod-primary]
}

# Provision Stage Cluster
module "stage" {
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id              = module.project-services.project_id
  name                    = "${var.gke_name}-stage"
  regional                = false
  region                  = var.default_region
  network                 = var.network
  subnetwork              = var.subnetwork
  ip_range_pods           = var.ip_range_pods
  ip_range_services       = var.ip_range_services
  zones             = var.default_zone
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  #release_channel         = "RAPID"
  node_pools = [
    {
      name         = "default-pool"
      autoscaling  = false
      auto_upgrade = true
      # ASM requires minimum 4 nodes and e2-standard-4
      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]
}

# Retrieve Cluster Credentials
resource "null_resource" "configure_kubectl_stage" {
    provisioner "local-exec" {
        command = "gcloud container clusters get-credentials ${module.stage.name} --zone ${module.stage.location} --project ${data.google_client_config.current.project}"
    }
    depends_on = [module.stage]
}

## Insert Lines Here
