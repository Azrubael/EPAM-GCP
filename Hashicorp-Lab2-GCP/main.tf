variable "GCP_PROJECT_ID" {
    default = "example"
}
variable "MY_NETWORK" {
    default = "terraform-network"
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
  project = "${var.GCP_PROJECT_ID}"
}


resource "google_compute_network" "vpc_network" {
  name = "${var.MY_NETWORK}"
}
