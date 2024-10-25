terraform {
  backend "gcs" {
    bucket      = "az-537298-bucket"
    prefix      = "terraform/state"
    credentials = "/home/vagrant/.env/az-537298-GCP.json"
  }
}