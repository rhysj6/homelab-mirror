resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}

resource "random_password" "cookie_signing_key" {
  length  = 64
  special = false
}

resource "kubernetes_secret" "postgres_creds" {
  metadata {
    name      = "authentik-postgres-creds"
    namespace = kubernetes_namespace.authentik.id
  }
  data = {
    username = data.infisical_secrets.db_creds.secrets.AUTHENTIK_USERNAME.value
    password = data.infisical_secrets.db_creds.secrets.AUTHENTIK_PASSWORD.value
  }
}

resource "helm_release" "authentik" {
  chart       = "authentik"
  repository  = "https://charts.goauthentik.io/"
  name        = "authentik"
  namespace   = kubernetes_namespace.authentik.id
  version     = "2025.8.3"
  max_history = 2
  depends_on  = [kubernetes_namespace.authentik]
  values = [yamlencode({
    authentik = {
      secret_key = random_password.cookie_signing_key.result,
      postgresql = {
        host     = "postgresql-rw.cnpg-system.svc.cluster.local"
        user     = "file:///postgres-creds/username"
        password = "file:///postgres-creds/password"
      }
    },
    global = {
      volumes = [
        {
          name = "cluster-domain-cert"
          secret = {
            secretName = "authentik-server-tls"
            items = [
              {
                key  = "tls.crt"
                path = "fullchain.pem"
              },
              {
                key  = "tls.key"
                path = "privkey.pem"
              }
            ]
          }
        },
        {
          name = "postgres-creds"
          secret = {
            secretName = kubernetes_secret.postgres_creds.metadata[0].name
          }
        }
      ]
      volumeMounts = [
        {
          name      = "cluster-domain-cert"
          mountPath = "/certs/domain"
          readOnly  = true
        },
        {
          name      = "postgres-creds"
          mountPath = "/postgres-creds"
          readOnly  = true
        }
      ]
    }
    server = {
      ingress = {
        enabled = true,
        hosts = [
          local.url,
        ],
        tls = [
          {
            hosts = [
              local.url,
            ],
            secretName = "authentik-server-tls",
          }
        ],
        annotations = {
          "cert-manager.io/cluster-issuer" = "cert-manager"
        }
      },
      metrics = {
        enabled = true,
        serviceMonitor = {
          enabled = true
        }
      },
    },
    redis = {
      enabled = true,
      master = {
        nodeSelector = {
          storage_enabled = "true"
        }
      }
    }
  })]
}
