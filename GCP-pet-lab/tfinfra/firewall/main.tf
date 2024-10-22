### Create firewall rules

variable "vpc_network" {
  description = "The self link of My VPC network"
  type        = string
}
variable "region" {
  description = "The region for the resources"
  type        = string
}


resource "google_compute_firewall" "allow_petclinic_from_internet" {
  name    = "allow-petclinic-from-internet"
  network = var.vpc_network

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["petclinic-firewall"]
}


resource "google_compute_firewall" "allow_mysql_from_petclinic" {
  name    = "allow-mysql-from-petclinic"
  network = var.vpc_network

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["mysqlserver-firewall"]
}


resource "google_compute_firewall" "allow_ssh_from_internet" {
  name    = "allow-ssh-from-internet"
  network = var.vpc_network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["petclinic-firewall", "mysqlserver-firewall"]
}
