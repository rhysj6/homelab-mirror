module "gateway" {
    source = "../../modules/gateway"
    domain = var.domain
    secondary_domain = var.secondary_domain
    windows_domain = var.windows_domain
}

module "pihole" {
  source           = "../../modules/pihole"
  domain           = var.domain
  windows_domain   = var.windows_domain
  load_balancer_ip = "10.21.0.53"
}
