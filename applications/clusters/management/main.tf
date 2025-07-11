module "semaphore" {
  source       = "../../modules/semaphore"
  domain       = var.domain
}

module "jenkins" {
  source       = "../../modules/jenkins"
  domain       = var.domain
}
