variable GCP_PROJECT_ID {
  description = "Value of GCP_PROJECT_ID"
  type = string
}
variable GCP_REGION {
  description = "Value of GCP_REGION"
  type = string
}
variable GCP_ZONE {
  description = "Value of GCP_ZONE"
  type = string
}
variable GCP_KEY_FILE {
  description = "Value of GCP_KEY_FILE"
  type = string
}
variable GCP_SERVICE_ACCOUNT {
  description = "Value of GCP_SERVICE_ACCOUNT"
  type = string
}
variable MY_VPC {
  description = "My VPC network name"
  type = string
  default = "petclinic-vpc"
}
variable MY_FILES {
  description = "My files to provision petclinic servers"
  type = list(string)
  default = [
    "app/spring-petclinic.jar",
    "app/__cacert_entrypoint.sh",
    "app/start_app.sh",
    "app/petclinic.service",
    ".env/env_local",
    ".env/petclinic.env",
    ".env/mysqlserver.env",
  ]
}
