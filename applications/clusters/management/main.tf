module "jenkins" {
  source       = "../../modules/jenkins"
  domain       = var.domain
}

module "infisical" {
  source       = "../../modules/infisical"
  domain       = var.domain
}
