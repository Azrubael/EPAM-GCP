# 2024-10-15    10:05
=====================

# Lab2 -- Creating Resource Dependencies with Terraform 
=======================================================

    Use variables and output values
    Observe implicit dependency
    Create explicit resource dependency

-----
Username:
    
Password:
    
PROJECT_ID:
    project_id
Region:
    my_region
Zone:
    my_zone

=======================================================
    $ mkdir tfinfra && cd $_
    $ vim provider.tf
---------------------------------------------
    $ cat provider.tf
provider "google" {
  project = "project_id"
  region  = "my_region"
  zone    = "my_zone"
}
---------------------------------------------

    $ vim instance.tf
---------------------------------------------
    $ cat instance.tf
resource google_compute_instance "vm_instance" {
name         = "${var.instance_name}"
zone         = "${var.instance_zone}"
machine_type = "${var.instance_type}"

boot_disk {
  initialize_params {
    image = "debian-cloud/debian-11"
  }
}

network_interface {
  network = "default"
  access_config {
    # Allocate a one-to-one NAT IP to the instance
    nat_ip = google_compute_address.vm_static_ip.address
  }
}

resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}
---------------------------------------------

    $ vim variables.tf
---------------------------------------------
    $ cat variables.tf
variable "instance_name" {
  type        = string
  description = "Name for the Google Compute instance"
}

variable "instance_zone" {
  type        = string
  description = "Zone for the Google Compute instance"
}

variable "instance_type" {
  type        = string
  description = "Disk type of the Google Compute instance"
  default     = "e2-medium"
}
---------------------------------------------

    $ vim outputs.tf
---------------------------------------------
    $ cat outputs.tf
output "network_IP" {
  value = google_compute_instance.vm_instance.instance_id
  description = "The internal ip address of the instance"
}

output "instance_link" {
  value = google_compute_instance.vm_instance.self_link
  description = "The URI of the created resource."
}



    $ terraform init
    $ terraform fmt && terraform validate
    $ terraform plan
# If prompted, enter the details for the instance creation as shown below:
var.instance_name: myinstance
var.instance_zone: my_zone

    $ terraform apply

# If prompted, enter the details for the instance creation as shown below:
var.instance_name: myinstance
var.instance_zone: my_zone


# you can use depends_on to explicitly declare the dependency.

    $ vim exp.tf
---------------------------------------------
    $ cat exp.tf
resource "google_compute_instance" "another_instance" {

  name         = "terraform-instance-2"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  # Tells Terraform that this VM instance must be created only after the
  # storage bucket has been created.
  depends_on = [google_storage_bucket.example_bucket]
}

resource "google_storage_bucket" "example_bucket" {
  name     = "<UNIQUE-BUCKET-NAME>"
  location = "US"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}
---------------------------------------------


    $ terraform plan
# If prompted, enter the details for the instance creation as shown below:
var.instance_name: myinstance
var.instance_zone: my_zone

    $ terraform apply
# If prompted, enter the details for the instance creation as shown below:
var.instance_name: myinstance
var.instance_zone: my_zone


### Task 5. View Dependency Graph
    $ terraform graph | dot -Tpng > graph.png



### To understand how to read this graph, please visit this page:
https://developer.hashicorp.com/terraform/internals/graph