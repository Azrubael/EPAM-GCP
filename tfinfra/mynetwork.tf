# Create the network "mynetwork"
resource "google_compute_network" "mynetwork" {
    name = "mynetwork"
    # RESOURCE properties go here
    auto_create_subnetworks = "true"
}

# Add a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
    name = "mynetwork-allow-htp-ssh-rdp-icmp"
    # RESOURCE properties go here
    network = google_compute_network.mynetwork.self_link
    allow {
        protocol = "tcp"
        ports = ["22", "80", "3389"]
    }

    allow {
        protocol = "icmp"
    }
    source_ranges = ["0.0.0.0/0"]
}

# Create the instance "mynet-us-vm"
module "mynet-us-vm" {
    source = "./instance"
    instance_name = "mynet-us-vm"
    instance_zone = "us-central1-f"
    instance_subnetwork = google_compute_network.mynetwork.self_link
}
# Create the instance "mynet-asia-vm"
module "mynet-asia-vm" {
    source = "./instance"
    instance_name = "mynet-asia-vm"
    instance_zone = "asia-east1-d"
    instance_subnetwork = google_compute_network.mynetwork.self_link
}