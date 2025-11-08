resource "kubernetes_namespace" "authentik" {
  metadata {
    name = "authentik"
  }
}
