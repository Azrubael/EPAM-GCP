terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.5.0"
    }
  }
}

### Configure the Google Cloud Provider
provider "google" {
  credentials = file(var.GCP_KEY_FILE)
  project = var.GCP_PROJECT_ID
  region = var.GCP_REGION
  zone = var.GCP_ZONE
}