include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependencies {
  paths = ["../postgresql"]
}

terraform {
  source = "."
}
