
# Cluster
resource "google_container_cluster" "prod-primary" {
  name               = "${var.gke_name}-prod-primary"
  location           = var.default_zone
  initial_node_count = 4

  depends_on = [google_project_service.container]

}
# Cluster Credentials
resource "null_resource" "configure_kubectl_prod_primary" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.prod-primary.name} --zone ${google_container_cluster.prod-primary.location} --project ${data.google_client_config.current.project}"
  }
  depends_on = [google_container_cluster.prod-primary]
}


resource "google_container_cluster" "prod-secondary" {
  name               = "${var.gke_name}-prod-secondary"
  location           = var.secondary_zone
  initial_node_count = 4

  depends_on = [google_project_service.container]

}
# Cluster Credentials
resource "null_resource" "configure_kubectl_prod_secondary" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.prod-secondary.name} --zone ${google_container_cluster.prod-secondary.location} --project ${data.google_client_config.current.project}"
  }
  depends_on = [google_container_cluster.prod-secondary]
}


## Insert Lines Here

# Provision Stage Cluster
resource "google_container_cluster" "stage" {
    name               = "${var.gke_name}-stage"
    location           = var.default_zone
    initial_node_count = 4

    depends_on = [google_project_service.container]
}

# Retrieve Cluster Credentials
resource "null_resource" "configure_kubectl_stage" {
    provisioner "local-exec" {
        command = "gcloud container clusters get-credentials ${google_container_cluster.stage.name} --zone ${google_container_cluster.stage.location} --project ${data.google_client_config.current.project}"
    }
    depends_on = [google_container_cluster.stage]
}