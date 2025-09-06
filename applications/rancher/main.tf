
resource "kubernetes_namespace" "rancher" {
  metadata {
    name = "cattle-system"
  }
  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = "2.12.1"
  namespace  = kubernetes_namespace.rancher.id
  set = [
    {
      name  = "hostname"
      value = "rancher.hl.${var.domain}"
    },
    {
      name  = "ingress.extraAnnotations.cert-manager\\.io/cluster-issuer"
      value = "cert-manager"
    },
    {
      name  = "ingress.tls.source"
      value = "secret"
    },
    {
      name  = "replicas"
      value = 1
    },
    {
      name  = "agentTLSMode"
      value = "system-store"
    }
  ]
}
