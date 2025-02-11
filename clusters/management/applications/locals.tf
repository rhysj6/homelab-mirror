
locals {
  environment = "redcliff" // TODO: Change this to management when moving to "production"
  domain = data.infisical_secrets.bootstrap_secrets.secrets["domain"].value
  cluster_subdomain = data.infisical_secrets.kubernetes_secrets.secrets["cluster_subdomain"].value
  authentik_host = data.infisical_secrets.bootstrap_secrets.secrets["authentik_hostname"].value
}