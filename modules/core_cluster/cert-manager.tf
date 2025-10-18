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
    "cloudflare-api-token" = data.infisical_secrets.core.secrets.cloudflare_api_key.value
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
        email = data.infisical_secrets.core.secrets.cloudflare_email.value
        # Name of a secret used to store the ACME account private key
        privateKeySecretRef = {
          name = "cert-manager-private-key"
        }
        # Enable the HTTP-01 challenge provider
        solvers = [
          {
            dns01 = {
              cloudflare = {
                email = data.infisical_secrets.core.secrets.cloudflare_email.value
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



resource "kubernetes_secret" "infisical_cluster_issuer" {
  metadata {
    name      = "infisical-cluster-issuer"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  data = {
    "clientSecret" = infisical_identity_universal_auth_client_secret.cert-manager.client_secret
  }
}

resource "kubernetes_manifest" "infisical_cluster_issuer" {
  count = (local.infisical_pki_crd_exists ? 1 : 0) ## Only create the ClusterIssuer if the CRD exists (will require a re-run if the CRD is created by the Helm release)
  manifest = {
    apiVersion = "infisical-issuer.infisical.com/v1alpha1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "infisical"
    }
    spec = {
      url = data.infisical_secrets.common.secrets.infisical_url.value
      projectId = data.infisical_secrets.common.secrets.certs_project_id.value
      certificateTemplateName = "default"
      authentication = {
        universalAuth = {
          clientId = infisical_identity_universal_auth_client_secret.cert-manager.client_id
          secretRef = {
            name = kubernetes_secret.infisical_cluster_issuer.metadata[0].name
            key  = "clientSecret"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.cert_manager, helm_release.cert_manager, kubernetes_secret.cluster_issuer]
}
