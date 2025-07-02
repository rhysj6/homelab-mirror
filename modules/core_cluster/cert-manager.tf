resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  chart       = "cert-manager"
  repository  = "https://charts.jetstack.io"
  name        = "cert-manager"
  namespace   = kubernetes_namespace.cert_manager.id
  version     = "v1.18.2"
  max_history = 2
  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
    {
      name  = "prometheus.enabled"
      value = local.prometheus_crd_exists
    },
    {
      name  = "prometheus.podmonitor.enabled"
      value = local.prometheus_crd_exists
    }
  ]
}

resource "kubernetes_secret" "cluster_issuer" {
  metadata {
    name      = "cluster-issuer"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  data = {
    "cloudflare-api-token" = var.cloudflare_api_key
  }
}

data "cloudflare_zones" "zones" {}

resource "kubernetes_manifest" "cluster_issuer" {
  count = (local.cert_manager_crd_exists ? 1 : 0) ## Only create the ClusterIssuer if the CRD exists (will require a re-run if the CRD is created by the Helm release)
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "cert-manager"
    }
    spec = {
      acme = {
        # The ACME server URL
        server = "https://acme-v02.api.letsencrypt.org/directory"
        # Email address used for ACME registration
        email = var.cloudflare_email
        # Name of a secret used to store the ACME account private key
        privateKeySecretRef = {
          name = "cert-manager-private-key"
        }
        # Enable the HTTP-01 challenge provider
        solvers = [
          {
            dns01 = {
              cloudflare = {
                email = var.cloudflare_email
                apiTokenSecretRef = {
                  name = "cluster-issuer"
                  key  = "cloudflare-api-token"
                }
              }
            }
            selector = {
              dnsZones = [for zone in data.cloudflare_zones.zones.result : zone.name]
            }
          }
        ]
      }
    }
  }
  depends_on = [kubernetes_namespace.cert_manager, helm_release.cert_manager, kubernetes_secret.cluster_issuer]
}
