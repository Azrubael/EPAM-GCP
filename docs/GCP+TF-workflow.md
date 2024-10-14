# 2024-10-14    13:25
=====================

### Google Cloud Authenticate
-----------------------------
Ensure that the VM has the Google Cloud API enabled.
If you're running Terraform outside Google Cloud, you can use a Google Cloud Service Account with Terraform.
From the service account key page in the Cloud Console, choose an existing account or create a new one.
Then download the JSON key file.
Name it something you can remember, and store it somewhere secure on your machine.
Supply the key to Terraform using the environment variable GOOGLE_APPLICATION_CREDENTIALS, setting the value to the location of the file.
Terraform can then use this key for authentication.
This method does have a few limitations.
Service account keys are short-lived.
Key rotation is not allowed, and the keys must be protected.
Workload identity and workload identity federation are tools for mitigating short-lived identity tokens when running Terraform outside of Google Cloud.
Once you've downloaded Terraform and authenticated successfully, you’re ready to start authoring a Terraform configuration. 


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
    id                              = "projects/example/global/networks/terraform-network"
    internal_ipv6_range             = null
    mtu                             = 0
    name                            = "terraform-network"
    project                         = "az-537298"
    routing_mode                    = "REGIONAL"
    self_link                       = "https://www.googleapis.com/compute/v1/projects/example/global/networks/terraform-network"


    $ terraform destroy