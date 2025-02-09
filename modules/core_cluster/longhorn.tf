resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  chart       = "longhorn"
  repository  = "https://charts.longhorn.io"
  name        = "longhorn"
  namespace   = kubernetes_namespace.longhorn.id
  version     = "1.8.0"
  max_history = 2
  set {
    name  = "ingress.enabled"
    value = true
  }
  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = resource.kubernetes_manifest.cluster_issuer.manifest.metadata.name
  }
  set {
    name  = "ingress.tls"
    value = true
  }
  set {
    name  = "ingress.host"
    value = "longhorn.${data.infisical_secrets.kubernetes.secrets["cluster_subdomain"].value}"
  }
}

// Note: Make sure to deal with multi-path issues per node https://longhorn.io/kb/troubleshooting-volume-with-multipath/