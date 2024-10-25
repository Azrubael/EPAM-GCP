variable "gcp_service_account" {
  description = "Value of GCP_SERVICE_ACCOUNT"
  type        = string
}
variable "gcp_project_id" {
  description = "Value of GCP_PROJECT_ID"
  type        = string
}
variable "vm_type" {
  description = "Virtual machine type for petclinic servers"
  type        = string
  default     = "e2-micro"
}
variable "sql_zone" {
  description = "GCP zone for MySQL server"
  type        = string
}
variable "sql_srv" {
  description = "MySQL database server name"
  type        = string
}
variable "sql_template_link" {
  description = "MySQL server GCP image link"
  type        = string
}
variable "sql_subnet" {
  description = "MySQL private subnet name"
  type        = string
}
variable "sql_firewall" {
  description = "MySQL private subnet firewall name"
  type        = string
}
