variable "firstrun" {
  description = "Whether this is the first run of the module"
  type        = bool
  default     = false
}

variable "secondrun" {
  description = "Whether this is the second run of the module"
  type        = bool
  default     = false
}

module "cluster" {
  source       = "../../../modules/downstream_cluster"
  cluster_name = "redcliff"
  domain       = var.domain
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
  domain = var.domain
  cloudflare_email = var.cloudflare_email
  cloudflare_api_key = var.cloudflare_api_key
}

module "dns" {
  count        = var.firstrun ? 0 : 1
  source = "../modules/pihole"
  domain = var.domain
  windows_domain = var.windows_domain
  load_balancer_ip = "10.20.1.53"
}
