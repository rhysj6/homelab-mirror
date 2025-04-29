module "core" {
  source                           = "../../../modules/core_cluster"
  cluster_name                     = "test"
  cilium_loadbalancer_ip_pool_cidr = "10.21.30.1/24"
  ingress_controller_ip            = "10.21.30.11"
  monitoring_ip                    = "10.21.30.12"
  cilium_use_bgp                   = true
  cilium_bgp_asn                   = 65553
  cluster_node_ips = [
    "10.20.30.11",
    "10.20.30.12",
    "10.20.30.13"
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