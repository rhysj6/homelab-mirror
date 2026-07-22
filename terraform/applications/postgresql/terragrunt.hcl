include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "kubernetes_providers" {
  path = find_in_parent_folders("kubernetes.hcl")
}


include "env" {
  path   = find_in_parent_folders("env_inputs.hcl")
  expose = true
}

dependencies {
  paths = ["../cnpg"]
}

terraform {
  source = "."
}

inputs = {
  databases = [
    "authentik",
    "infisical",
    "netbox"
  ]
}
