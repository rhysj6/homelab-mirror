resource "kubernetes_service_v1" "aovpn" {
  metadata {
    name      = "aovpn"
    namespace = kubernetes_namespace.external_hosts.metadata[0].name
  }
  spec {
    type          = "ExternalName"
    external_name = "192.1.0.21"
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_manifest" "aovpn_ingress_route" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRouteTCP"
    metadata = {
      name      = "aovpn-ingress"
      namespace = kubernetes_namespace.external_hosts.metadata[0].name
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "HostSNI(`aovpn.${var.windows_domain}`)"
          services = [
            {
              name = "aovpn"
              port = 80
            }
          ]
        }
      ]
      tls = {
        secretName = "aovpn-tls"
      }
    }
  }
}

resource "kubernetes_manifest" "aovpn_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "aovpn-tls"
      namespace = kubernetes_namespace.external_hosts.metadata[0].name
    }
    spec = {
      dnsNames = [
        "aovpn.${var.windows_domain}",
      ]
      secretName = "aovpn-tls"
      issuerRef = {
        name = "cert-manager"
        kind = "ClusterIssuer"
      }
    }
  }
}
