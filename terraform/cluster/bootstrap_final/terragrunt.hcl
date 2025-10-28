include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

dependencies {
  paths = ["../talos", "../bootstrap_init"]
}

terraform {
  source = "."
}

inputs = {
  cluster_name = include.env.locals.cluster
}