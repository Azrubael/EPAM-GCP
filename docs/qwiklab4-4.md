# 2024-10-13    11:10
=====================

# Lab4-4 -- Automating the Deployment of Infrastructure Using Terraform 
=======================================================================
Create a configuration for an auto mode network
Create a configuration for a firewall rule
Create a module for VM instances
Create and deploy a configuration
Verify the deployment of a configuration
-----
Username:
    
Password:
    
PROJECT_ID:
    
Region1:
    
Zone1:
    
Region2:
    
Zone2:    



In this lab, you created a Terraform configuration with a module to automate the deployment of GCP infrastructure usung *Coogle Cloud Shell*.
As your configuration changes, Terraform can create incremental execution plans, which allocates you to build your overall configuration step-by-step.
The Instance module allowed you to reuse the same resource configuration for multiple resources while providing properties as input variables.
You can leverage the configuration and module that you created as a starting point for future deployments. 

### Workflow
------------
    $ teraform --version

    $ mkdir tfinfra
    $ cd tfinfra
    $ mkdir instance

    $ vim provider.tf
    $ cat provider.tf
provider "google" {}

    $ terraform init
    ...
* provider.google version = "-> 2.12"
    ...

    $ terraform validate
# OR or if you need to validate for Google guardrails
    $ gcloud beta terraform vet

#########################################################
    $ vim mynetwork.tf
    $ cat mynetwork.tf
# Create the network "mynetwork"
resource [RESOURCE_TYPE] "mynetwork" {
    name = [RESOURCE_NAME]
    # RESOURCE properties go here
}

# Add a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on mynetwork
resource [RESOURCE_TYPE] "mynetwork-allow-http-ssh-rdp-icmp" {
    name = [RESOURCE_NAME]
    # RESOURCE properties go here
}

#########################################################
    $ vim mynetwork.tf
    $ cat mynetwork.tf
# Create the network "mynetwork"
resource "google_compute_network" "mynetwork" {
    name = "mynetwork"
    auto_create_subnetworks = true
}

# Add a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
    name = "mynetwork-allow-htp-ssh-rdp-icmp"
    network = google_compute_network.mynetwork.self_link
    allow {
        protocol = "tcp"
        ports = ["22", "80", "3389"]
    }

    allow {
        protocol = "icmp"
    }
}

# Create the instance "mynet-us-vm"
module "mynet-us-vm" {
    source = "./instance"
    instance_name = "mynet-us-vm"
    instance_zone = "us-central1-a"
    instance_subnetwork = google_compute_network.mynetwork.self_link
}
# Create the instance "mynet-us-vm"
module "mynet-us-vm" {
    source = "./instance"
    instance_name = "mynet-eu-vm"
    instance_zone = "europe-west1-d"
    instance_subnetwork = google_compute_network.mynetwork.self_link
}

#########################################################

    $ cd instance
    $ vim main.tf
    $ cat main.tf
resource [RESOURCE_TYPE] "vm_instance" {
    name = [RESOURCE_NAME]
    # RESOURCE properties go here
}

#########################################################

    $ vim main.tf
    $ cat main.tf
variable "instance_name" {}
variable "instance_zone" {}
variable "instance_type" {
    default = "n1-standard-1"
}
variable "instance_subnetwork" {}

resource "google_compute_instance" "vm_instance" {
    name = "${var.instance_name}"
    zone = "${var.instance_zone}"
    machine_type = "${var.instance_type}"

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        subnetwork = "${var.instance_subnetwork}"
        access_config {
            # Allocate a one-to-one NAT IP to the interface
        }
    }
    
}


    $ cd ~/tfinfra
    $ terraform fmt     ###  To check synthax
mynetwork.tf

    $ terraform init
    ...
* provider.google version = "-> 2.12"
    ...

    $ terraform plan
    ...
Plan: 4 to add, 0 to change, 0 to destroy.

    $ terraform apply

...

    $ $ terraform destroy