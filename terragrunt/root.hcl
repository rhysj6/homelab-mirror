locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  s3_path  = "${replace(path_relative_to_include(), "//.terragrunt-stack//", "/")}"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "terraform"
    key            = "${local.s3_path}/terraform.tfstate"
    region                      = "main"
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    use_path_style              = true
    use_lockfile                = true
  }
}
EOF
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("${get_repo_root()}/terraform/versions.tf")
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("${get_repo_root()}/terraform/providers.tf")
}
