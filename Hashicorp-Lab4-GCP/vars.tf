variable GCP_PROJECT_ID { }
variable GCP_REGION { }
variable GCP_ZONE { }
variable GCP_KEY_FILE {}
variable MY_NETWORK {
    default = "terraform-network"
}
variable OS_TYPE {
    default = "debian-cloud/debian-11"
}
variable VM_TYPE {
    default = "f1-micro"
}
