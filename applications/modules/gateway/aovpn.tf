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
      name = "http"
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
      routes = [
        {
          match = "HostSNI(`aovpn.${var.windows_domain}`)"
          services = [
            {
              name = "aovpn"
              port = "http"
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
      commonName = "aovpn.${var.windows_domain}"
      dnsNames = [
        "aovpn.${var.windows_domain}"
      ]
      secretName = "aovpn-tls"
      issuerRef = {
        name = "cert-manager"
        kind = "ClusterIssuer"
      }
      additionalOutputFormats = [
        {
          type = "CombinedPEM"
        }
      ]

    }
  }
}
