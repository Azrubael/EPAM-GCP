# 2024-10-15    13:38
=====================

# Lab4 -- Creating a Remote Backend
===================================

    Create a local backend.
    Create a Cloud Storage backend.
    Refresh your Terraform state.

-----
Username:
    
Password:
    
PROJECT_ID:
    
Region:
    
Zone:
    

=======================================================

# Task 3. Add a local backend
### Retrieve your Google Cloud Project ID:
    $ gcloud config list --format 'value(core.project)'
    $ mkdir tfinfra && cd $_
    $ vim main.tf
-----------------------------------
    $ cat main.tf
provider "google" {
  project     = "Project ID"
  region      = "Region"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
}
terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
-----------------------------------

    $ terraform init
    $ terraform apply
    $ terraform show


# Task 4. Add a Cloud Storage backend
### Navigate back to your main.tf file in the editor. You will now replace the current local backend with a gcs backend.
    $ vim main.tf
-----------------------------------
    $ cat main.tf
provider "google" {
  project     = "Project ID"
  region      = "Region"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
}
terraform {
  backend "gcs" {
    bucket  = "Project ID"
    prefix  = "terraform/state"
  }
}
-----------------------------------

    $ terraform init -migrate-state


# Task 5. Refresh the state
### In the Cloud Console, in the Navigation menu, click Cloud Storage and then Bucket.
### Click on your bucket and navigate to the file terraform/state/default.tfstate.
### Your state file now exists in a Cloud Storage bucket!

  The `terraform refresh` command is used to reconcile the state Terraform knows about (via its state file) with the real-world infrastructure. This can be used to detect any drift from the last-known state and to update the state file. This does not modify infrastructure, but does modify the state file. If the state is changed, this may cause changes to occur during the next plan or apply.
  Return to your storage bucket in the Cloud Console.
  Select the check box next to the name.
  Click the Labels button on the top.
  The info panel with Labels tabs will open up.
  Click +ADD LABEL. Set the Key1 = key and Value1 = value.
Click Save.

    $ terraform refresh


# Task 6. Clean up the workspace
### Note: If you try to delete a bucket that contains objects, Terraform will fail that run.
### First, revert your backend to local so you can delete the storage bucket. 
    $ vim main.tf
-----------------------------------
    $ cat main.tf
provider "google" {
  project     = "Project ID"
  region      = "Region"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
}
terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
-----------------------------------

    $ terraform init -migrate-state

In the `main.tf` file, add the `force_destroy = true` argument to your google_storage_bucket resource. When you delete a bucket, this boolean option will delete all contained objects.
    $ vim main.tf
-----------------------------------
    $ cat main.tf
provider "google" {
  project     = "Project ID"
  region      = "Region"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "Project ID"
  location    = "US" # Replace with EU for Europe region
  uniform_bucket_level_access = true
  force_destroy = true
}
terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
-----------------------------------

    $ terraform apply
    $ terraform show
    $ terraform destroy

