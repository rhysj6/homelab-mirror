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