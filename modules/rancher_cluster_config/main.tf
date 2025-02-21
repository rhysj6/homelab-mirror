terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "6.0.0"
    }
  }
}

variable "cluster_name" {
  description = "The name of the cluster"
}

variable "fleet_namespace" {
  description = "The namespace where the Fleet components are installed"
  default = "fleet-default"
}
data "rancher2_cluster_v2" "cluster" {
  name            = var.cluster_name
  fleet_namespace = var.fleet_namespace
}

output "cluster_exists" {
  value = data.rancher2_cluster_v2.cluster.id != null
}

## The kube_config may be null if the cluster is not ready so we need to check for that before trying to access it
locals {
  kubeconfig = try(yamldecode(data.rancher2_cluster_v2.cluster.kube_config), null)
}

output "host" {
    value = local.kubeconfig != null ? local.kubeconfig.clusters[0].cluster.server : null
}

output "token" {
    value = local.kubeconfig != null ? local.kubeconfig.users[0].user.token : null
}