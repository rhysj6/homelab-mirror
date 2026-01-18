include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependencies {
  paths = ["../cnpg"]
}

terraform {
  source = "."
}

inputs = {
  env = include.env.locals.env
  loadbalancer_ip = include.env.locals.network.ips.postgresql
  databases = [
    "authentik",
    "infisical",
    "netbox"
  ]
}
