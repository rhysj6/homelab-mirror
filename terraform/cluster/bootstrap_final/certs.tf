
resource "kubernetes_secret" "cluster_issuer" {
  metadata {
    name      = "cluster-issuer"
    namespace = "cert-manager"
  }
  data = {
    "cloudflare-api-token" = data.infisical_secrets.core.secrets.cloudflare_api_key.value
  }
}

data "cloudflare_zones" "zones" {}

resource "kubernetes_manifest" "cluster_issuer" {
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
  depends_on = [kubernetes_secret.cluster_issuer]
}


resource "kubernetes_manifest" "infisical_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "infisical"
    }
    spec = {
      acme = {
        server = "${data.infisical_secrets.common.secrets.infisical_url.value}/api/v1/cert-manager/acme/profiles/5bd9a3f7-1673-48be-a30d-3d2670de4da0/directory"

        # disableAccountKeyGeneration = true
        externalAccountBinding = {
          keyID = "5bd9a3f7-1673-48be-a30d-3d2670de4da0"
          keySecretRef = {
            name = "infisical-cluster-issuer"
            key  = "clientSecret"
          }
        }
        privateKeySecretRef = {
          name = "infisical-acme-private-key"
        }
      }
    }
  }
  depends_on = [kubernetes_secret_v1.infisical_cluster_issuer]
}

resource "kubernetes_secret_v1" "infisical_cluster_issuer" {
  metadata {
    name      = "infisical-cluster-issuer"
    namespace = "cert-manager"
  }
  data = {
    "clientSecret" = data.infisical_secrets.core.secrets.infisical_acme_client_secret.value
  }
}
