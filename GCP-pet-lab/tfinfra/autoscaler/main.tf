variable "autoscaler_name" {}
variable "autoscaler_region" {}
variable "autoscaler_target" {}
variable "autoscaler_policy_mode" {}
variable "autoscaler_min_size" {}
variable "autoscaler_max_size" {}
variable "autoscaler_cooldown" {}
variable "autoscaler_cpu_target" {}
  

# Region Autoscaler Basic
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler

resource "google_compute_region_autoscaler" "pc_mig_autoscaler" {
  name   = var.autoscaler_name
  region = var.autoscaler_region
  target = var.autoscaler_target
  autoscaling_policy {
    mode            = var.autoscaler_policy_mode
    min_replicas    = var.autoscaler_min_size
    max_replicas    = var.autoscaler_max_size
    cooldown_period = var.autoscaler_cooldown
    cpu_utilization {
      target = var.autoscaler_cpu_target
    }
  }
}