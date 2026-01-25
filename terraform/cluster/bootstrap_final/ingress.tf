
resource "kubernetes_manifest" "local_only_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "local-only"
      namespace = "traefik"
    }
    spec = {
      ipAllowList = {
        sourceRange = ["10.0.0.0/8", "192.168.0.0/16"]
      }
    }
  }
}


resource "kubernetes_manifest" "authentik_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "authentik"
      namespace = "traefik"
    }
    spec = {
      forwardAuth = {
        address            = "${data.infisical_secrets.common.secrets.authentik_url.value}/outpost.goauthentik.io/auth/traefik"
        trustForwardHeader = true
        authResponseHeaders = [
          "X-authentik-username",
          "X-authentik-groups",
          "X-authentik-entitlements",
          "X-authentik-email",
          "X-authentik-name",
          "X-authentik-uid",
          "X-authentik-jwt",
          "X-authentik-meta-jwks",
          "X-authentik-meta-outpost",
          "X-authentik-meta-provider",
          "X-authentik-meta-app",
          "X-authentik-meta-version"
        ]
      }
    }
  }
}
