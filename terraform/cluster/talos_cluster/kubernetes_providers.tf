provider "kubernetes" {
    host = "https://${local.control_plane_endpoints[0]}:6443"
    cluster_ca_certificate = local.k8s_cluster_ca_certificate
    client_certificate = local.k8s_client_certificate
    client_key = local.k8s_client_key
}

provider "helm" {
  kubernetes = {
    host                   = "https://${local.control_plane_endpoints[0]}:6443"
    cluster_ca_certificate = local.k8s_cluster_ca_certificate
    client_certificate     = local.k8s_client_certificate
    client_key             = local.k8s_client_key
  }
}