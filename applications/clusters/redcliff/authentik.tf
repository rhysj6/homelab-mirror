module "authentik" {
  source       = "../../modules/authentik/app"
  domain       = var.domain  
}