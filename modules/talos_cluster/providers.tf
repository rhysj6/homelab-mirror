provider "kubernetes" {
    host = "https://${var.node_1_ip}:6443"
    cluster_ca_certificate = local.k8s_cluster_ca_certificate
    client_certificate = local.k8s_client_certificate
    client_key = local.k8s_client_key
}

provider "helm" {
  kubernetes = {
    host                   = "https://${var.node_1_ip}:6443"
    cluster_ca_certificate = local.k8s_cluster_ca_certificate
    client_certificate     = local.k8s_client_certificate
    client_key             = local.k8s_client_key
  }
}