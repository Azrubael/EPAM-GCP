variable "GCP_PROJECT_ID" {
    default = "example"
}
variable "GCP_REGION" {
    default = "us-central1"
}
variable "GCP_ZONE" {
    default = "us-central1-c"
}
variable "MY_NETWORK" {
    default = "terraform-network"
}
variable "OS_TYPE" {
    default = "debian-cloud/debian-11"
}
variable "VM_TYPE" {
    default = "f1-micro"
}


terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.GCP_PROJECT_ID
  region = var.GCP_REGION
  zone = var.GCP_ZONE
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
