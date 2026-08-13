unit "nginx" {
  source = "${get_repo_root()}/terraform/applications/nginx"
  path   = "nginx"
}

unit "mcp_test" {
  source = "${get_repo_root()}/terraform/applications/mcp-testing"
  path   = "mcp-testing"
}