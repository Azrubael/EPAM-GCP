/*
 * The training configuration on GCP to study the order
 * of creating a simple infrastructure that includes:
 * VPC, subnets, firewall, NAT, Auto Scaler, Managed Group etc.
 */


### Create a VPC
resource "google_compute_network" "vpc" {
  provider                = google-beta
  name                    = "petclinic-vpc"
  auto_create_subnetworks = false
}


### Create subnets
resource "google_compute_subnetwork" "proxy_subnet" {
  provider      = google-beta
  name          = "pc-proxy-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.GCP_REGION
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "pc_subnet" {
  provider      = google-beta
  name          = "pc-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.GCP_REGION
  network       = google_compute_network.vpc.self_link
}


resource "google_compute_subnetwork" "sql_subnet" {
  provider      = google-beta
  name          = "mysql-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.GCP_REGION
  network       = google_compute_network.vpc.self_link
}


### Import firewall rules module
module "firewall" {
  source        = "./firewall"
  firewall_vpc  = google_compute_network.vpc.self_link
  pc_port          = "$var.PC_PORT"
  sql_port         = "$var.SQL_PORT"
  ssh_port         = "$var.SSH_PORT"
  }


### Backend Health Check
resource "google_compute_region_health_check" "petclinic_health_check" {
  provider              = google-beta
  name                  = "petclinic-health-check"
  check_interval_sec    = 30
  timeout_sec           = 10
  healthy_threshold     = 2
  unhealthy_threshold   = 2

  http_health_check {
    port                = var.PC_PORT
    proxy_header        = "NONE"
    request_path        = "/"
  }
}

# Internal Http Lb With Mig Backend
 # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule
resource "google_compute_forwarding_rule" "default" {
  provider              = google-beta
  name                  = "petclinic-http-forwarding-rule"
  region                = google_compute_subnetwork.pc_subnet.region
  depends_on            = [google_compute_subnetwork.proxy_subnet]
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = var.LOAD_BALANCER_TYPE
  target                = google_compute_region_target_http_proxy.petclinic_http_proxy.id
  network               = google_compute_network.vpc.id
  network_tier          = "PREMIUM"
}

# Target HTTP Proxy
resource "google_compute_region_target_http_proxy" "petclinic_http_proxy" {
  provider              = google-beta
  name                  = "petclinic-http-proxy"
  region                = google_compute_subnetwork.proxy_subnet.region
  url_map               = google_compute_region_url_map.petclinic_url_map.id
  depends_on = [ google_compute_subnetwork.pc_subnet ]
}

# URL map
resource "google_compute_region_url_map" "petclinic_url_map" {
  provider              = google-beta
  name                  = "petclinic-url-map"
  region                = var.GCP_REGION
  default_service       = google_compute_region_backend_service.petclinic_backend.id
  depends_on = [ google_compute_subnetwork.pc_subnet ]
}

# Backend Service External MANAGED LB
resource "google_compute_region_backend_service" "petclinic_backend" {
  provider              = google-beta
  name                  = "petclinic-backend"
  region                = var.GCP_REGION
  protocol              = "HTTP"
  load_balancing_scheme = var.LOAD_BALANCER_TYPE
  locality_lb_policy    = "ROUND_ROBIN"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.petclinic_health_check.id]
  backend {
    group               = google_compute_region_instance_group_manager.pc_mig.instance_group
    balancing_mode      = "UTILIZATION"
    capacity_scaler     = 1.0 
    failover            = false
    max_utilization     = 0.7
  }
  depends_on = [google_compute_subnetwork.pc_subnet]
}


# Regional Instance Group Manager API
# https://registry.terraform.io/providers/hashicorp/google/6.5.0/docs/resources/compute_region_instance_group_manager
resource "google_compute_region_instance_group_manager" "pc_mig" {
  provider            = google
  name                = var.PC_MIG
  base_instance_name  = var.PC_SRV
  region              = var.GCP_REGION
  distribution_policy_zones  = [
                      "${var.GCP_REGION}-a",
                      "${var.GCP_REGION}-b",
                      "${var.GCP_REGION}-c",
                      "${var.GCP_REGION}-f"
                      ]
  # target_size         = var.MIN_SIZE  # for use without autoscaler
  version {
    name              = "${var.PC_SRV}-primary"
    instance_template = var.PC_TEMPLATE_LINK
  }
  named_port {
    name = "http"
    port = var.PC_PORT
  }
  auto_healing_policies {
    health_check      = google_compute_region_health_check.petclinic_health_check.self_link
    initial_delay_sec = 60
  }
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "RESTART"
    max_unavailable_fixed = 4
  }
  depends_on = [google_compute_subnetwork.pc_subnet]
}


module "nat" {
  gcp_project_id              = var.GCP_PROJECT_ID
  source                      = "./nat"
  router_name                 = "petclinic-router"
  router_region               = google_compute_subnetwork.pc_subnet.region
  router_vpc                  = google_compute_network.vpc.id

  nat_name                    = "pc-nat-gateway"
  nat_ip_option               = "AUTO_ONLY"
  ip_ranges_to_nat            = "LIST_OF_SUBNETWORKS"
  subnet_name                 = google_compute_subnetwork.pc_subnet.id
  ip_ranges_to_nat_subnetwork = ["ALL_IP_RANGES"]
  log_filter                  = "ERRORS_ONLY"
  log_enable                  = false

  depends_on                  = [google_compute_subnetwork.pc_subnet]
}


module "autoscaler" {
  source                 = "./autoscaler"
  autoscaler_name        = "${var.PC_MIG}-autoscaler"
  autoscaler_region             = var.GCP_REGION
  autoscaler_target      = google_compute_region_instance_group_manager.pc_mig.self_link
  autoscaler_policy_mode = "ON"
  autoscaler_min_size    = var.MIN_SIZE
  autoscaler_max_size    = var.MAX_SIZE
  autoscaler_cooldown    = 60
  autoscaler_cpu_target  = 0.6
  depends_on = [ 
    google_compute_subnetwork.pc_subnet,
    google_compute_region_health_check.petclinic_health_check,
    google_compute_region_instance_group_manager.pc_mig
    ]
}


### Import database module
module "database" {
  gcp_project_id        = var.GCP_PROJECT_ID
  gcp_service_account   = var.GCP_SERVICE_ACCOUNT
  source                = "./database"
  vm_type               = var.SQL_VM_TYPE
  sql_zone              = var.SQL_ZONE
  sql_srv               = var.SQL_SRV
  sql_template_link     = var.SQL_IMAGE_LINK
  sql_subnet            = google_compute_subnetwork.sql_subnet.self_link
  sql_firewall          = var.SQL_FIREWALL
}
