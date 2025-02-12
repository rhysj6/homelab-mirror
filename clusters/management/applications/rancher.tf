
resource "kubernetes_namespace" "rancher" {
  metadata {
    name = "cattle-system"
  }
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/stable"
  chart      = "rancher"
  version    = "2.10.2"
  namespace  = kubernetes_namespace.rancher.id
  set {
    name  = "hostname"
    value = "rancher.hl.${local.domain}"
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
}
