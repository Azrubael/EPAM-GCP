variable "GCP_PROJECT_ID" {
  type = string
}

variable "GCP_REGION" {
  type = string
}

variable "MY_FILES" {
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