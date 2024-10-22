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
variable VM_TYPE {
  description = "Virtual machine type for petclinic servers"
  type = string
  default = "g1-small"
}
variable PC_SUBNET {
  description = "Petclinic subnet name"
  type = string
  default = "pc-subnet"
}
variable PC_FIREWALL {
  description = "Petclinic firewall name"
  type = string
  default = "petclinic-firewall"
}
variable PC_SRV {
  description = "Petclinic server name"
  type = string
  default = "petclinic-server"
}
variable PC_IMAGE {
  description = "Petclinic image name"
  type = string
  default = "petclinic-image"
}
variable PC_TEMPLATE_LINK {
  description = "Petclinic GCP template link"
  type = string
  default = "projects/az-537298/regions/us-central1/instanceTemplates/petclinic-template"
}
variable SQL_SUBNET {
  description = "MySQL private subnet name"
  type = string
  default = "mysql-subnet"
}
variable SQL_FIREWALL {
  description = "MySQL private subnet firewall name"
  type = string
  default = "mysqlserver-firewall"
}
variable SQL_SRV {
  description = "MySQL database server name"
  type = string
  default = "mysql-server"
}
variable SQL_IMAGE {
  description = "MySQL server image name"
  type = string
  default = "mysqlserver-image"
}
variable SQL_TEMPLATE_LINK {
  description = "MySQL server GCP template link"
  type = string
  default = "projects/az-537298/regions/us-central1/instanceTemplates/mysqlserver-template"
}
