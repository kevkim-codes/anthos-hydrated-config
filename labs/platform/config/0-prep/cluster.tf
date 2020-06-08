
# Cluster
resource "google_container_cluster" "prod" {
  name               = "${var.gke_name}-prod"
  location           = var.default_zone
  initial_node_count = 4
}
# Cluster Credentials
resource "null_resource" "configure_kubectl_prod" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.prod.name} --zone ${google_container_cluster.prod.location} --project ${data.google_client_config.current.project}"
  }
  depends_on = [google_container_cluster.prod]
}


resource "google_container_cluster" "stage" {
  name               = "${var.gke_name}-stage"
  location           = var.default_zone
  initial_node_count = 4
}
# Cluster Credentials
resource "null_resource" "configure_kubectl_stage" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.stage.name} --zone ${google_container_cluster.stage.location} --project ${data.google_client_config.current.project}"
  }
  depends_on = [google_container_cluster.stage]
}


resource "google_container_cluster" "dev" {
  name               = "${var.gke_name}-dev"
  location           = var.default_zone
  initial_node_count = 4
}
# Cluster Credentials
resource "null_resource" "configure_kubectl_dev" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.dev.name} --zone ${google_container_cluster.dev.location} --project ${data.google_client_config.current.project}"
  }
  depends_on = [google_container_cluster.dev]
}

