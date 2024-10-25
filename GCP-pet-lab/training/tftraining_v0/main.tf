/*
* Option for training infrastructure configuration on GCP
* to study the order of launching a configuration that has
* VPC, subnets, firewall, NAT, Auto Scaler, Managed Group
*/

# Create a VPC
resource "google_compute_network" "vpc" {
  name                    = "petclinic-vpc"
  auto_create_subnetworks = false
}

# Create subnets
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

# Import firewall rules module
module "firewall" {
  source = "./firewall"
  vpc_network = google_compute_network.vpc.self_link
  region = var.GCP_REGION
}


# ----- The new generated code that have to be tested 
resource "google_compute_health_check" "petclinic_health_check" {
  name = "petclinic-health-check"
  check_interval_sec = 30
  timeout_sec = 10
  healthy_threshold  = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 8080
    request_path = "/health"
  }
}

resource "google_compute_region_backend_service" "petclinic_backend" {
  name = "petclinic-backend"
  # protocol  = "HTTP"
  region = var.GCP_REGION
  health_checks = [google_compute_health_check.petclinic_health_check.id]
  connection_draining_timeout_sec = 10
  session_affinity                = "CLIENT_IP"
}

resource "google_compute_forwarding_rule" "default" {
  name     = "petclinic-forwarding-rule"
  region   = var.GCP_REGION

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.petclinic_backend.id
  all_ports             = true
  network               = google_compute_network.vpc.self_link
  subnetwork            = google_compute_subnetwork.pc_subnet.self_link
}

resource "google_compute_router" "pc_router" {
  name    = "petclinic-router"
  region  = google_compute_subnetwork.pc_subnet.region
  network = google_compute_network.vpc.id
}

# resource "google_compute_route" "pc_route" {
#   name    = "pc_route"
#   dest_range = "0.0.0.0/0"
#   network = google_compute_network.vpc.self_link
#   next_hop_ilb = google_compute_forwarding_rule.default.id
#   priority = 2000
# }

resource "google_compute_router_nat" "pc_nat_gateway" {
  name = "pc-nat-gateway"
  router = google_compute_router.pc_router.name
  region = var.GCP_REGION
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    filter = "ERRORS_ONLY" # one of ["ERRORS_ONLY" "TRANSLATIONS_ONLY" "ALL"]
    enable = false
  }
}

# resource "google_compute_url_map" "petclinic_url_map" {
#   name = "petclinic-url-map"
#   default_service = google_compute_region_backend_service.petclinic_backend.self_link
# }

# resource "google_compute_target_http_proxy" "petclinic_http_proxy" {
#   name = "petclinic-http-proxy"
#   url_map = google_compute_url_map.petclinic_url_map.id
# }

# resource "google_compute_global_forwarding_rule" "petclinic_forwarding_rule" {
#   name = "petclinic-forwarding-rule"
#   target = google_compute_target_http_proxy.petclinic_http_proxy.id
#   port_range = "80"
# }

resource "google_compute_instance_group_manager" "pc_mig" {
  # provider           = google-beta
  name               = var.PC_MIG
  base_instance_name = var.PC_SRV
  zone = var.GCP_ZONE
  target_size        = var.MIN_SIZE
  target_pools = [ google_compute_target_pool.pc_pool.id ]
  version {
    name = "${var.PC_SRV}v"
    instance_template  = var.PC_TEMPLATE_LINK
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.petclinic_health_check.self_link
    initial_delay_sec = 300
  }
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "RESTART"
    max_unavailable_fixed = 1
    max_surge_fixed       = 0
  }

}

resource "google_compute_autoscaler" "pc_mig_autoscaler" {
  name    = "${var.PC_MIG}-autoscaler"
  zone  = var.GCP_ZONE
  target  = google_compute_instance_group_manager.pc_mig.self_link
  autoscaling_policy {
    mode = "ON"
    min_replicas = var.MIN_SIZE
    max_replicas = var.MAX_SIZE
    cooldown_period = 60
    cpu_utilization {
      target = 0.8
    }
  }
}

resource "google_compute_target_pool" "pc_pool" {
  name = "petclinic-pool"
}

