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
  databases = [
    "authentik",
    "infisical",
    "netbox"
  ]
}
