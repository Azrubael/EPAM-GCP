variable GCP_PROJECT_ID {
  type = string
}
variable GCP_REGION {
  type = string
}
variable GCP_ZONE {
  type = string
}
variable GCP_KEY_FILE {
  type = string
}
variable GCP_SERVICE_ACCOUNT {
  type = string
}
variable MY_VPC {
  type = string
  default = "petclinic-vpc"
}
variable MY_FILES {
  type = list(string)
  default = [
    "app/__cacert_entrypoint.sh",
    "app/start_app.sh",
    "app/petclinic.service",
    ".env/env_local",
    ".env/petclinic.env",
    ".env/mysqlserver.env",
  ]
}
variable MY_ARTIFACT {
  type = string
  default = "app/spring-petclinic.jar"
}
variable VM_TYPE {
  type = string
  default = "g1-small"
}
variable PC_SUBNET {
  type = string
  default = "pc-subnet"
}
variable PC_FIREWALL {
  type = string
  default = "petclinic-firewall"
}
variable PC_SRV {
  type = string
  default = "petclinic-server"
}
variable PC_IMAGE {
  type = string
  default = "petclinic-image"
}
variable PC_TEMPLATE {
  type = string
  default = "petclinic-template"
}
variable SQL_SUBNET {
  type = string
  default = "mysql-subnet"
}
variable SQL_FIREWALL {
  type = string
  default = "mysqlserver-firewall"
}
variable SQL_SRV {
  type = string
  default = "mysql-server"
}
variable SQL_IMAGE {
  type = string
  default = "mysqlserver-image"
}
variable SQL_TEMPLATE {
  type = string
  default = "mysqlserver-template"
}
