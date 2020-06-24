# Variable definitions go here

variable "default_region" {
  description = "The default region to be used"
}
variable "default_zone" {
    type        = list(string)
  description = "The default zone to be used"
}
variable "secondary_zone" {
  description = "The secondary zone to be used"
}

variable "gke_name" {
  description = "The name of the GKE cluster"
}

variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "acm_operator_path" {
  description = "The path to config management operator yaml"
}
variable "acm_repo_location" {
  description = "The location of the git repo ACM will sync to"
}



variable "network" {
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
}

