terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.7.0"
    }
  }
}


### Configure the Google Cloud Provider
provider "google" {
  credentials = file(var.GCP_KEY_FILE)
  project     = var.GCP_PROJECT_ID
  region      = var.GCP_REGION
}

provider "google-beta" {
  credentials = file(var.GCP_KEY_FILE)
  project     = var.GCP_PROJECT_ID
  region      = var.GCP_REGION
}
