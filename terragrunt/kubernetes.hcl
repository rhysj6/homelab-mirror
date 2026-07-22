locals {
    env = yamldecode(file(find_in_parent_folders("env.yaml")))
}

generate "kubernetes_providers" {
  path      = "kubernetes_providers.tf"
  if_exists = "skip" # The talos modules generate the secrets so we skip this file there
  contents  = <<EOF
ephemeral "infisical_secret" "kubernetes_host" {
  name         = "${upper(local.env.cluster_name)}_HOST"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
}
ephemeral "infisical_secret" "kubernetes_cluster_ca_certificate" {
  name         = "${upper(local.env.cluster_name)}_CLUSTER_CA_CERTIFICATE"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
}

ephemeral "infisical_secret" "kubernetes_client_certificate" {
  name         = "${upper(local.env.cluster_name)}_CLIENT_CERTIFICATE"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
}

ephemeral "infisical_secret" "kubernetes_client_key" {
  name         = "${upper(local.env.cluster_name)}_CLIENT_KEY"
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/providers/kubeconfigs"
}


provider "kubernetes" {
    host = ephemeral.infisical_secret.kubernetes_host.value
    cluster_ca_certificate = ephemeral.infisical_secret.kubernetes_cluster_ca_certificate.value
    client_certificate = ephemeral.infisical_secret.kubernetes_client_certificate.value
    client_key = ephemeral.infisical_secret.kubernetes_client_key.value
}

provider "helm" {
  kubernetes = {
    host                   = ephemeral.infisical_secret.kubernetes_host.value
    cluster_ca_certificate = ephemeral.infisical_secret.kubernetes_cluster_ca_certificate.value
    client_certificate     = ephemeral.infisical_secret.kubernetes_client_certificate.value
    client_key             = ephemeral.infisical_secret.kubernetes_client_key.value
  }
}
EOF
}
