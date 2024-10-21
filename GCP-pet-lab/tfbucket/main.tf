### Create a Cloud Storage bucket
resource "google_storage_bucket" "bucket" {
  name          = "${var.GCP_PROJECT_ID}-bucket"
  location      = var.GCP_REGION
  storage_class = "STANDARD"
}

### Upload text files to Cloud Storage
resource "google_storage_bucket_object" "files" {
  for_each = toset(var.MY_FILES)
  name     = each.value
  source   = "../${each.value}"
  bucket   = google_storage_bucket.bucket.name
}
