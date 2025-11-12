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
  version     = "v1.19.1"
  max_history = 2
  set = [
    {
      name  = "crds.enabled"
      value = "true"
    }
  ]
  depends_on = [ helm_release.kube_prometheus_stack, kubernetes_namespace.cert_manager ]
}

resource "helm_release" "infisical_pki_operator" {
  chart       = "infisical-pki-issuer"
  repository  = "https://dl.cloudsmith.io/public/infisical/helm-charts/helm/charts"
  name        = "infisical-pki-issuer"
  namespace   = kubernetes_namespace.cert_manager.id
  version     = "v0.1.0"
  max_history = 2
  depends_on = [ helm_release.cert_manager ]
}
