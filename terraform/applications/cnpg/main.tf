variable "env" {
    description = "The environment name"
    type        = string
}

resource "helm_release" "cloud_native_postgres" {
  chart            = "cloudnative-pg"
  repository       = "https://cloudnative-pg.github.io/charts"
  name             = "cloud-native-postgres"
  namespace        = "cnpg-system"
  create_namespace = true
  version          = "0.26.1"
  max_history      = 2
}
