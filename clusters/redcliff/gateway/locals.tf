locals {
  domain = data.infisical_secrets.bootstrap.secrets["domain"].value
}