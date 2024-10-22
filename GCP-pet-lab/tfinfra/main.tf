### Create a VPC
resource "google_compute_network" "vpc" {
  name                    = "petclinic-vpc"
  auto_create_subnetworks = false
}

### Create subnets
resource "google_compute_subnetwork" "pc_subnet" {
  name          = "pc-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.self_link
  region        = var.GCP_REGION
}

resource "google_compute_subnetwork" "sql_subnet" {
  name          = "mysql-subnet"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc.self_link
  region        = var.GCP_REGION
}

### Import firewall rules module
module "firewall" {
  source = "./firewall"
  vpc_network = google_compute_network.vpc.self_link
  region = var.GCP_REGION
}

/*
### Create a managed instances group
resource "google_compute_instance_group_manager" "group_manager" {
  name               = "pc-group-manager"
  base_instance_name = var.PC_SRV
  zone               = var.GCP_ZONE
  target_size        = 2
  version {
    instance_template = google_compute_instance_template.pc_template.self_link
  }
  named_port {
    name = "http"
    port = 8080
  }
}
variable GCP_AUTOSCALE_ZONES {
  description = "value of GCP_AUTOSCALE_ZONES"
  type = list(string)
  default = [
    "${var.GCP_REGION}-a",
    "${var.GCP_REGION}-b",
    "${var.GCP_REGION}-c",
    "${var.GCP_REGION}-f"
  ]
}
*/