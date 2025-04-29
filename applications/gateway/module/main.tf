resource "kubernetes_namespace" "external_hosts" {
  metadata {
    name = "external-hosts"
  }
}

module "clifton" {
  source     = "./pass_through_ingress"
  name       = "clifton"
  hostname   = "clifton.hl.${var.domain}"
  ip_address = "10.0.0.20"
  port       = 8006
  portname = "https"
}

module "pbs" {
  source     = "./pass_through_ingress"
  name       = "pbs"
  hostname   = "pbs.hl.${var.domain}"
  ip_address = "10.10.0.25"
  port       = 8007
  portname = "https"
}

module "home_assistant" {
  source     = "./pass_through_ingress"
  name       = "home-assistant"
  hostname   = "ha.${var.domain}"
  ip_address = "10.10.0.4"
  port       = 8123
}

module "paperless" {
  source     = "./pass_through_ingress"
  name       = "paperless"
  hostname   = "paperless.${var.domain}"
  ip_address = "10.10.1.4"
  port       = 8000
}

module "portainer" {
  source     = "./pass_through_ingress"
  name       = "portainer"
  hostname   = "portainer.hl.${var.domain}"
  ip_address = "10.10.1.10"
  port       = 9000
}

module "secrets" {
  source     = "./pass_through_ingress"
  name       = "infisical"
  hostname   = "secrets.hl.${var.domain}"
  ip_address = "10.10.1.10"
  port       = 80
}
module "semaphore" {
  source     = "./pass_through_ingress"
  name       = "semaphore"
  hostname   = "semaphore.hl.${var.domain}"
  ip_address = "10.10.1.10"
  port       = 3000
}

module "vcenter" {
  source     = "./pass_through_ingress"
  name       = "vcenter"
  hostname   = "vcenter.${var.secondary_domain}"
  ip_address = "ddns.${var.secondary_domain}"
  port       = 443
  portname = "https"
}