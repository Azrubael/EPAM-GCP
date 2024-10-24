variable "GCP_PROJECT_ID" {
  description = "Value of GCP_PROJECT_ID"
  type        = string
}
variable "GCP_REGION" {
  description = "Value of GCP_REGION"
  type        = string
}
variable "GCP_KEY_FILE" {
  description = "Value of GCP_KEY_FILE"
  type        = string
}
variable "GCP_SERVICE_ACCOUNT" {
  description = "Value of GCP_SERVICE_ACCOUNT"
  type        = string
}


variable "LOAD_BALANCER_TYPE" {
  description = "Maximum number of petclinic servers"
  type        = string
  default     = "EXTERNAL_MANAGED"
}
variable "MAX_SIZE" {
  description = "Maximum number of petclinic servers"
  type        = number
  default     = 4
}
variable "MIN_SIZE" {
  description = "Minimum number of petclinic servers"
  type        = number
  default     = 2
}
variable "MY_VPC" {
  description = "My VPC network name"
  type        = string
  default     = "petclinic-vpc"
}


variable "PC_FIREWALL" {
  description = "Petclinic firewall name"
  type        = string
  default     = "petclinic-firewall"
}
variable "PC_IMAGE" {
  description = "Petclinic image name"
  type        = string
  default     = "petclinic-image"
}
variable "PC_MIG" {
  description = "Petclinic managed instance group name"
  type        = string
  default     = "pc-mig"
}
variable "PC_PORT" {
  description = "Petclinic managed instance group name"
  type        = number
  default     = 8080
}
variable "PC_SRV" {
  description = "Petclinic server name"
  type        = string
  default     = "petclinic-server"
}
variable "PC_SUBNET" {
  description = "Petclinic subnet name"
  type        = string
  default     = "pc-subnet"
}
variable "PC_TEMPLATE_LINK" {
  description = "Petclinic GCP template link"
  type        = string
  default     = "projects/az-537298/regions/us-central1/instanceTemplates/petclinic-template"
}


variable "SSH_PORT" {
  description = "SSH port"
  type        = number
  default     = 22
}


variable "SQL_FIREWALL" {
  description = "MySQL private subnet firewall name"
  type        = string
  default     = "mysqlserver-firewall"
}
variable "SQL_IMAGE" {
  description = "MySQL server image name"
  type        = string
  default     = "mysqlserver-image"
}
variable "SQL_IMAGE_LINK" {
  description = "MySQL server GCP image link"
  type        = string
  default     = "projects/az-537298/global/images/mysqlserver-image"
}

variable "SQL_PORT" {
  description = "MySQL database server port"
  type        = number
  default     = 3306
}
variable "SQL_SRV" {
  description = "MySQL database server name"
  type        = string
  default     = "mysql-server"
}
variable "SQL_SUBNET" {
  description = "MySQL private subnet name"
  type        = string
  default     = "mysql-subnet"
}
variable "SQL_VM_TYPE" {
  description = "Virtual machine type for MySQL server"
  type        = string
  # default     = "g1-small"  # only for morning hours by Kyiv
  default     = "e2-micro"
}
variable "SQL_ZONE" {
  description = "GCP zone for MySQL server"
  type        = string
}
