# 2024-10-13    18:16
=====================

    $ terraform init

    $ terraform fmt

    $ terraform validate

    $ gcloud auth application-default login --no-launch-browser

    $ terraform plan

    $ terreform apply

    $ cat terraform.tfstate
# OR
    $ terraform show
# google_compute_network.vpc_network:
resource "google_compute_network" "vpc_network" {
    auto_create_subnetworks         = true
    delete_default_routes_on_create = false
    description                     = null
    enable_ula_internal_ipv6        = false
    gateway_ipv4                    = null
    id                              = "projects/az-537298/global/networks/terraform-network"
    internal_ipv6_range             = null
    mtu                             = 0
    name                            = "terraform-network"
    project                         = "az-537298"
    routing_mode                    = "REGIONAL"
    self_link                       = "https://www.googleapis.com/compute/v1/projects/az-537298/global/networks/terraform-network"


    $ terraform destroy