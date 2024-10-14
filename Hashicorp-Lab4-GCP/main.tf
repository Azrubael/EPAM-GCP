terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}


resource "google_compute_network" "vpc_network" {
  name = var.MY_NETWORK
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.VM_TYPE
  tags = ["http-server","dev-server"]

  boot_disk {
    initialize_params {
      image = var.OS_TYPE
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}
