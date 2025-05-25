
resource "kubernetes_namespace" "rancher" {
  metadata {
    name = "cattle-system"
  }
  lifecycle {
    ignore_changes = [ metadata[0].annotations ]
  }
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = "2.11.2"
  namespace  = kubernetes_namespace.rancher.id
  set {
    name  = "hostname"
    value = "rancher.hl.${var.domain}"
  }
  set {
    name  = "ingress.extraAnnotations.cert-manager\\.io/cluster-issuer"
    value = "cert-manager"
  }
  set {
    name  = "ingress.tls.source"
    value = "secret"
  }
  set {
    name = "replicas"
    value = 1
  }
  set {
    name  = "agentTLSMode"
    value = "system-store"
  }
}
