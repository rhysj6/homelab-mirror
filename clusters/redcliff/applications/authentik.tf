resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}

resource "random_password" "authentik_secret" {
  length  = 64
  special = false
}

resource "random_password" "authentik_db" {
  length  = 64
  special = false
}

resource "helm_release" "authentik" {
  chart       = "authentik"
  repository  = "https://charts.goauthentik.io/"
  name        = "authentik"
  namespace   = kubernetes_namespace.authentik.id
  version     = "2024.12.3"
  max_history = 2
  depends_on  = [kubernetes_namespace.authentik]
  values = [yamlencode({
    authentik = {
      secret_key = random_password.authentik_secret.result,
      postgresql = {
        password = random_password.authentik_db.result
      }
    },
    global = {
      volumes = [
        {
          name = "cluster-domain-cert"
          secret = {
            secretName  = "authentik-server-tls"
            # defaultMode = "0666"
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
        }
      ]
      volumeMounts = [
        {
          name      = "cluster-domain-cert"
          mountPath = "/certs/domain"
          readOnly  = true
        }
      ]
    }
    server = {
      ingress = {
        enabled = true,
        hosts = [
          "hl.${data.infisical_secrets.bootstrap.secrets["domain"].value}"
        ],
        tls = [
          {
            hosts = [
              "hl.${data.infisical_secrets.bootstrap.secrets["domain"].value}"
            ],
            secretName = "authentik-server-tls",
          }
        ],
        annotations = {
          "cert-manager.io/cluster-issuer" = "cert-manager"
        }
      }
    },
    postgresql = {
      enabled = true,
      auth = {
        password = random_password.authentik_db.result
      }
    },
    redis = {
      enabled = true,
    }
  })]
}
