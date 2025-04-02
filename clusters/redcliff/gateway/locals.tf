locals {
  domain = data.infisical_secrets.bootstrap.secrets["domain"].value
  other_domain = data.infisical_secrets.bootstrap.secrets["windows_domain"].value
}