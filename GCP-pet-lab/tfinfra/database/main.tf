variable "vm_type" {}
variable "gcp_service_account" {}
variable "gcp_project_id" {}
variable "gcp_zone" {}
variable "sql_srv" {}
variable "sql_template_link" {}
variable "sql_subnet" {}
variable "sql_firewall" {}


resource "google_compute_instance" "sql_srv" {
  name         = var.sql_srv
  machine_type = var.vm_type
  project      = var.gcp_project_id
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image   = var.sql_template_link
      size    = 10
      type    = "pd-standard"
    }
  }

  network_interface {
    subnetwork   = var.sql_subnet
  }

  service_account {
    email     = var.gcp_service_account
    scopes    = [ 
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring.write",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/trace.append"
     ]
  }

  tags = [
    "db-server",
    var.sql_firewall,
    var.sql_srv
  ]

  allow_stopping_for_update         = true

  shielded_instance_config {
    enable_secure_boot              = false
    enable_vtpm                     = true
    enable_integrity_monitoring     = true
  }

  labels = {
    app                             = "petclinic"
  }

}

