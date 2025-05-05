module "authentik" {
    source = "../../modules/authentik/config"
    domain = var.domain
}