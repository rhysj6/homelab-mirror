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

locals {
  versions = yamldecode(file(find_in_parent_folders("cluster_versions.yaml")))
  env_name = basename(dirname(find_in_parent_folders("env_inputs.hcl")))
}

dependency "nodes" {
  config_path  = "../talos_nodes"
  skip_outputs = true
  enabled      = local.env_name != "redcliff"
}

terraform {
  source = "."
}


inputs = {
  talos_version = local.versions.talos
  kubernetes_version = local.versions.applied_kubernetes_version
}