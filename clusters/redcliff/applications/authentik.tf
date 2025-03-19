resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}

resource "random_password" "authentik_secret" {
  length  = 64
  special = false
}

module "postgresql" {
  source                     = "../../../modules/postgres_cluster"
  namespace                  = kubernetes_namespace.authentik.id
  name                       = "authentik"
  cluster_name               = "test" ## TODO: Change this to the correct cluster name
  is_superuser_password_same = true
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
        host     = module.postgresql.service_name
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
            secretName = module.postgresql.secret_name
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
    redis = {
      enabled = true,
    }
  })]
}
