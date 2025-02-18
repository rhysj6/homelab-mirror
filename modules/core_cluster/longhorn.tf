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
    name  = "persistence.defaultClassReplicaCount"
    value = var.number_of_nodes
  }
}

// Note: Make sure to prepare nodes https://longhorn.io/docs/1.8.0/v2-data-engine/quick-start/#prerequisites