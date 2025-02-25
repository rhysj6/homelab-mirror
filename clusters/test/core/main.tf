variable "firstrun" {
  description = "Whether this is the first run of the module"
  type        = bool
  default     = false
}

module "cluster" {
  source       = "../../../modules/downstream_cluster"
  cluster_name = "test"
  firstrun     = var.firstrun
  providers = {
    kubernetes = kubernetes.management
  }
}

module "core" {
  count = var.firstrun ? 0 : 1
  source                           = "../../../modules/core_cluster"
  cluster_name                     = "test"
  cilium_loadbalancer_ip_pool_cidr = "10.20.31.1/24"
  ingress_controller_ip            = "10.20.31.11"
}