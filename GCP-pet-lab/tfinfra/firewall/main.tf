### Create petclinic firewall rules

variable "firewall_vpc" {
  description = "The self link of My VPC network"
  type        = string
}
variable "pc_port" {
  description = "Petclinic server port"
  type        = string
}
variable "sql_port" {
  description = "MySQL server port"
  type        = string
}
variable "ssh_port" {
  description = "SSH connection port"
  type        = string
}


resource "google_compute_firewall" "allow_petclinic_from_internet" {
  name    = "allow-petclinic-from-internet"
  network = var.firewall_vpc

  allow {
    protocol = "tcp"
    ports    = [var.pc_port]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["petclinic-firewall"]
}


resource "google_compute_firewall" "allow_mysql_from_petclinic" {
  name    = "allow-mysql-from-petclinic"
  network = var.firewall_vpc

  allow {
    protocol = "tcp"
    ports    = [var.sql_port]
  }
  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["mysqlserver-firewall"]
}


resource "google_compute_firewall" "allow_ssh_from_internet" {
  name    = "allow-ssh-from-internet"
  network = var.firewall_vpc

  allow {
    protocol = "tcp"
    ports    = [var.ssh_port]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["petclinic-firewall", "mysqlserver-firewall"]
}
