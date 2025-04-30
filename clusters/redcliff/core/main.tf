module "core" {
  source                           = "../../../modules/core_cluster"
  cluster_name                     = "redcliff"
  cilium_loadbalancer_ip_pool_cidr = "10.21.0.1/24"
  ingress_controller_ip            = "10.21.0.11"
  monitoring_ip                    = "10.21.0.12"
  cilium_use_bgp                   = true
  cilium_bgp_asn                   = 65555

  cluster_node_ips = [
    "10.20.0.11",
    "10.20.0.12",
    "10.20.0.13"
  ]
  domain             = var.domain
  cloudflare_email   = var.cloudflare_email
  cloudflare_api_key = var.cloudflare_api_key
}
