module "core" {
  source                           = "../../../modules/core_cluster"
  cluster_name                     = "management"
  cilium_loadbalancer_ip_pool_cidr = "10.21.1.1/24"
  ingress_controller_ip            = "10.21.1.11"
  monitoring_ip                    = "10.21.1.12"
  cilium_use_bgp                   = true
  cilium_bgp_asn                   = 65552
  number_of_nodes                  = 1
  cluster_node_ips = [
    "10.21.0.11"
  ]
  domain             = var.domain
  cloudflare_email   = var.cloudflare_email
  cloudflare_api_key = var.cloudflare_api_key
}

variable "domain" {
  description = "The domain name that most resources will be created under."
  type        = string
}

variable "cloudflare_email" {
  description = "The email address for Cloudflare"
  type        = string
}

variable "cloudflare_api_key" {
  description = "The API key for Cloudflare"
  type        = string
  sensitive   = true
}
