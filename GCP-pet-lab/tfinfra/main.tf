### Create a Cloud Storage bucket
resource "google_storage_bucket" "bucket" {
  name          = "${var.GCP_PROJECT_ID}-bucket"
  location      = var.GCP_REGION
  storage_class = "STANDARD"
}

### Upload files to Cloud Storage
resource "google_storage_bucket_object" "files" {
  count  = length(var.MY_FILES)
  bucket = google_storage_bucket.bucket.name
  name   = var.MY_FILES[count.index]
  source = file("../${var.MY_FILES[count.index]}")
}

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

### Create firewall rules
resource "google_compute_firewall" "allow_petclinic_from_internet" {
  name    = "allow-petclinic-from-internet"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["petclinic-firewall"]
}

resource "google_compute_firewall" "allow_mysql_from_petclinic" {
  name    = "allow-mysql-from-petclinic"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["10.0.1.0/24"]
  target_tags   = ["mysqlserver-firewall"]
}

resource "google_compute_firewall" "allow_ssh_from_internet" {
  name    = "allow-ssh-from-internet"
  network = google_compute_network.vpc.self_link

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
