# Variable definitions go here

variable "default_region" {
  description = "The default region to be used"
}
variable "default_zone" {
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
#variable "gke_location" {
#  description = "The zone or region for the GKE cluster"
#}

variable "operator_path" {
  description = "The path to config management operator yaml"
}