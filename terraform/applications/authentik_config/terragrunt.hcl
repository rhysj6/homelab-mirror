include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("env_inputs.hcl")
  expose = true
}

dependencies {
  paths = ["../authentik"]
}

terraform {
  source = ".//"
}
