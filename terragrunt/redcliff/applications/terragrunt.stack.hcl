unit "cnpg" {
  source = "${get_repo_root()}/terraform/applications/cnpg"
  path   = "cnpg"
}

unit "postgresql" {
  source = "${get_repo_root()}/terraform/applications/postgresql"
  path   = "postgresql"
}

unit "gateway" {
  source = "${get_repo_root()}/terraform/applications/gateway"
  path   = "gateway"
}

unit "authentik_app" {
  source = "${get_repo_root()}/terraform/applications/authentik"
  path   = "authentik"
}

unit "authentik_config" {
  source = "${get_repo_root()}/terraform/applications/authentik_config"
  path   = "authentik_config"
}

unit "infisical" {
  source = "${get_repo_root()}/terraform/applications/infisical"
  path   = "infisical"
}

unit "technitium_dns" {
  source = "${get_repo_root()}/terraform/applications/technitium_dns"
  path   = "technitium_dns"
}

unit "external_dns" {
  source = "${get_repo_root()}/terraform/applications/external_dns"
  path   = "external_dns"
}

unit "jenkins" {
  source = "${get_repo_root()}/terraform/applications/jenkins"
  path   = "jenkins"
}

unit "observability" {
  source = "${get_repo_root()}/terraform/applications/observability"
  path   = "observability"
}