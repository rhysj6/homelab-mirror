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
  count                            = 0
  source                           = "../../../modules/core_cluster"
  cluster_name                     = "management"
  main_node_ip                     = "10.20.10.11"
  cilium_loadbalancer_ip_pool_cidr = "10.20.11.1/24"
  ingress_controller_ip            = "10.20.11.11"
  number_of_nodes                  = 1
}
