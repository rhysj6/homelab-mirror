resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik_crds" {
  chart       = "traefik-crds"
  repository  = "https://traefik.github.io/charts"
  name        = "traefik-crds"
  namespace   = kubernetes_namespace.traefik.id
  version     = "1.11.0"
  max_history = 2
}


resource "helm_release" "traefik" {
  chart       = "traefik"
  repository  = "https://traefik.github.io/charts"
  name        = "traefik"
  namespace   = kubernetes_namespace.traefik.id
  version     = "37.1.0"
  max_history = 2
  depends_on  = [helm_release.traefik_crds, kubernetes_namespace.traefik]
  values = [
    templatefile("${path.module}/templates/traefik_values.yaml", {
      cilium_crds = data.kubernetes_resources.cilium_crds.objects
      service_ip  = var.ingress_controller_ip
    })
  ]
}

resource "kubernetes_manifest" "local_only_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "local-only"
      namespace = kubernetes_namespace.traefik.id
    }
    spec = {
      ipAllowList = {
        sourceRange = ["10.0.0.0/8"]
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
      namespace = kubernetes_namespace.traefik.id
    }
    spec = {
      forwardAuth = {
        address            = "https://hl.${var.domain}/outpost.goauthentik.io/auth/traefik"
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
