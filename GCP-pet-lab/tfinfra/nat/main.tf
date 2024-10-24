variable "gcp_project_id" {}
# variable "gcp_service_account" {}
variable "router_region" {}
variable "router_name" {}
variable "router_vpc" {}
variable "nat_name" {}
variable "nat_ip_option" {}
variable "ip_ranges_to_nat" {}
variable "ip_ranges_to_nat_subnetwork" {}
variable "subnet_name" {}
variable "log_filter" {}
variable "log_enable" {}


resource "google_compute_router" "pc_router" {
  name    = "petclinic-router"
  region  = var.router_region
  network = var.router_vpc
}


resource "google_compute_router_nat" "pc_nat_gateway" {
  name                               = "pc-nat-gateway"
  router                             = google_compute_router.pc_router.name
  region                             = google_compute_router.pc_router.region
  nat_ip_allocate_option             = var.nat_ip_option
  source_subnetwork_ip_ranges_to_nat = var.ip_ranges_to_nat
  subnetwork {
    name                    = var.subnet_name
    source_ip_ranges_to_nat = var.ip_ranges_to_nat_subnetwork
  }
  log_config {
    filter = var.log_filter
    enable = var.log_enable
  }
}
