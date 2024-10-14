terraform {
    requied_roviders {
        google = {
            source = "hashicorp/google"
            version = "4.27.0"
        }
    }
}

provider "google" {
    # Configuration options
    project = "example"
    region = "us-central1"
    zone = "us-central1-c"
}

resource "google_compute_instance" "terraform" {
    name = "terraform"
    # machine_type = "n1-standard-2"
    machine_type = "e2-micro"
    tags = ["web", "dev"]

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
    allow_stopping_for_update = true
}
