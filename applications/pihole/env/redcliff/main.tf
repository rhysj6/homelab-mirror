module "pihole" {
  source           = "../../module"
  domain           = var.domain
  windows_domain   = var.windows_domain
  load_balancer_ip = "10.21.0.53"
}
