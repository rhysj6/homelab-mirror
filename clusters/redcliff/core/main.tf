variable "firstrun" {
  description = "Whether this is the first run of the module"
  type        = bool
  default     = false
}

module "cluster" {
  source       = "../../../modules/downstream_cluster"
  cluster_name = "redcliff"
}

module "core" {
  count                            = var.firstrun ? 0 : 1
  source                           = "../../../modules/core_cluster"
  cluster_name                     = "redcliff"
  cilium_loadbalancer_ip_pool_cidr = "10.20.1.1/24"
  ingress_controller_ip            = "10.20.1.11"
  monitoring_ip                    = "10.20.1.12"
  cluster_node_ips = [
    "10.20.0.11",
    "10.20.0.12",
    "10.20.0.13"
  ]
}

module "authentik" {
  count        = var.firstrun ? 0 : 1
  source       = "../modules/authentik"
  domain = data.infisical_secrets.bootstrap.secrets["domain"].value
  depends_on   = [module.core]
}
