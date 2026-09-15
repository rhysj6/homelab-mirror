locals {
  github_ssh_keys_raw = jsondecode(data.http.github_ssh_keys.response_body)
  github_ssh_keys      = [for k in local.github_ssh_keys_raw : k.key]
  node_name = "clifton"
}

data "http" "github_ssh_keys" {
  url = "https://api.github.com/users/rhysj6/keys"

  request_headers = {
    Accept = "application/vnd.github+json"
  }
}
