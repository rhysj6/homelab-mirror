resource "kubernetes_service_v1" "management" {
  metadata {
    name      = "management-cluster-ingress"
    namespace = kubernetes_namespace.external_hosts.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "10.21.10.11"
    port {
      port        = 443
      target_port = 443
      name = "https"
    }
  }
}

resource "kubernetes_manifest" "management_ingress_route" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "management-cluster-ingress"
      namespace = kubernetes_namespace.external_hosts.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "HostSNI(`rancher.homelab.example`)"
          services = [
            {
              name = "management-cluster-ingress"
              port = "https"
            }
          ]
        },
        {
          match = "HostSNI(`jenkins.homelab.example`)"
          services = [
            {
              name = "management-cluster-ingress"
              port = "https"
            }
          ]
        },
        {
          match = "HostSNIRegexp(`.*management\\.rhysj6\\.com.*`)"
          services = [
            {
              name = "management-cluster-ingress"
              port = "https"
            }
          ]
        }
      ]
      tls = {
        passthrough = true
      }
    }
  }
}
