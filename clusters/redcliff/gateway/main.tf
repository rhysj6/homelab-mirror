resource "kubernetes_namespace" "external_hosts" {
  metadata {
    name = "external-hosts"
  }
}

module "clifton" {
  source     = "../modules/pass_through_ingress"
  name       = "clifton"
  hostname   = "clifton.hl.${local.domain}"
  ip_address = "10.0.0.20"
  port       = 8006
  portname = "https"
}

module "pbs" {
  source     = "../modules/pass_through_ingress"
  name       = "pbs"
  hostname   = "pbs.hl.${local.domain}"
  ip_address = "10.10.0.25"
  port       = 8007
}

module "home_assistant" {
  source     = "../modules/pass_through_ingress"
  name       = "home-assistant"
  hostname   = "ha.${local.domain}"
  ip_address = "10.10.0.4"
  port       = 8123
}

module "paperless" {
  source     = "../modules/pass_through_ingress"
  name       = "paperless"
  hostname   = "paperless.${local.domain}"
  ip_address = "10.10.1.4"
  port       = 8000
}

module "portainer" {
  source     = "../modules/pass_through_ingress"
  name       = "portainer"
  hostname   = "portainer.hl.${local.domain}"
  ip_address = "10.10.1.10"
  port       = 9000
}

module "secrets" {
  source     = "../modules/pass_through_ingress"
  name       = "infisical"
  hostname   = "secrets.hl.${local.domain}"
  ip_address = "10.10.1.10"
  port       = 80
}
module "semaphore" {
  source     = "../modules/pass_through_ingress"
  name       = "semaphore"
  hostname   = "semaphore.hl.${local.domain}"
  ip_address = "10.10.1.10"
  port       = 3000
}

module "static" {
  source     = "../modules/pass_through_ingress"
  name       = "vmwinwebsrv"
  hostname   = "static.hl.${local.domain}"
  ip_address = "10.10.0.50"
  port       = 8000
}

module "vcenter" {
  source     = "../modules/pass_through_ingress"
  name       = "vcenter"
  hostname   = "vcenter.${local.other_domain}"
  ip_address = "ddns.${local.other_domain}"
  port       = 443
  portname = "https"
}