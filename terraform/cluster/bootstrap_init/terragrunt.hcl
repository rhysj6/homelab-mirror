include "root" {
  path = find_in_parent_folders("root.hcl")
}
include "kubernetes_providers" {
  path = find_in_parent_folders("kubernetes.hcl")
}


include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependencies {
  paths = ["../talos_cluster"]
}

terraform {
  source = "."
}
