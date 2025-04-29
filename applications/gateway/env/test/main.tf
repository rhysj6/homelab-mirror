module "gateway" {
    source = "../../module"
    domain = var.domain
    secondary_domain = var.secondary_domain
    windows_domain = var.windows_domain
}