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
  version     = "v1.19.2"
  max_history = 2
  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
    {
      name  = "dns01RecursiveNameserversOnly"
      value = "true"
    },
    {
      name  = "dns01RecursiveNameservers"
      value = "1.1.1.1:53"
    }
  ]
  depends_on = [helm_release.kube_prometheus_stack, kubernetes_namespace.cert_manager]
}
