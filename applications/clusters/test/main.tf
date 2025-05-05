module "gateway" {
    source = "../../gateway/module"
    domain = var.domain
    secondary_domain = var.secondary_domain
    windows_domain = var.windows_domain
}