
locals {
  domain         = data.infisical_secrets.bootstrap_secrets.secrets["domain"].value
  authentik_host = data.infisical_secrets.bootstrap_secrets.secrets["authentik_hostname"].value
}