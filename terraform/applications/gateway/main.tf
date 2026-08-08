resource "kubernetes_namespace" "external_hosts" {
  metadata {
    name = "external-hosts"
  }
}

module "clifton" {
  source     = "./pass_through_ingress"
  name       = "clifton"
  hostname   = "clifton.homelab.example"
  ip_address = "10.0.0.20"
  port       = 8006
  portname   = "https"
  extra-ingress-annotations = {
    "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-authentik@kubernetescrd"
  }
}

module "pve-internal" {
  source     = "./pass_through_ingress"
  name       = "pve-internal"
  hostname   = "pve.homelab.example"
  ip_address = "10.0.0.20"
  port       = 8006
  portname   = "https"
  local-only = true
}


module "pbs" {
  source     = "./pass_through_ingress"
  name       = "pbs"
  hostname   = "pbs.homelab.example"
  ip_address = "10.0.0.25"
  port       = 8007
  portname   = "https"
  local-only = true
}

module "semaphore" {
  source     = "./pass_through_ingress"
  name       = "semaphore"
  hostname   = "semaphore.homelab.example"
  ip_address = "10.10.1.25"
  port       = 80
  local-only = true
}

module "home_assistant" {
  source     = "./pass_through_ingress"
  name       = "home-assistant"
  hostname   = "ha.example.com"
  ip_address = "10.10.1.10"
  port       = 8123
}

module "paperless" {
  source     = "./pass_through_ingress"
  name       = "paperless"
  hostname   = "paperless.example.com"
  ip_address = "10.10.1.4"
  port       = 8000
  local-only = true
}

module "actualbudget" {
  source     = "./pass_through_ingress"
  name       = "actual-budget"
  hostname   = "budget.example.com"
  ip_address = "10.10.1.5"
  port       = 5006
  portname   = "https"
  local-only = true
}

module "parox_immich" {
  source     = "./pass_through_ingress"
  name       = "parox-immich"
  hostname   = "immich.example.net"
  ip_address = "10.48.0.144"
  port       = 2283
}
