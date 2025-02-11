# terraform {
  # cloud {
  #   organization = "Homelab"
  #   workspaces {
  #     name = "Rancher_Cluster"
  #   }
  # }
# }
provider "kubernetes" {
  // Handled in the environment variables.
  config_path = "/workspaces/homelab/management_kubeconfig"
}
provider "helm" {
  kubernetes {
    // Handled in the environment variables.
    config_path = "/workspaces/homelab/management_kubeconfig"
  }
}