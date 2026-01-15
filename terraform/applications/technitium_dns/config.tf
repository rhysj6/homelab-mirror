resource "random_password" "admin_password" {
  length  = 32
  special = false
}


resource "kubernetes_secret_v1" "password" {
  metadata {
    name      = "technitium-admin-password"
    namespace = kubernetes_namespace.dns.metadata[0].name
  }
  data = {
    password = random_password.admin_password.result
  }
  type = "Opaque"
}

resource "kubernetes_config_map_v1" "technitium_config" {
  metadata {
    name      = "technitium-config"
    namespace = kubernetes_namespace.dns.metadata[0].name
  }
  data = {
    DNS_SERVER_DOMAIN = local.url
    DNS_SERVER_ENABLE_BLOCKING = "true"
    DNS_SERVER_BLOCK_LIST_URLS = <<-EOT
      https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
    EOT

    DNS_SERVER_FORWARDERS = <<-EOT
    https://dns.google/dns-query (8.8.8.8)
    https://dns.google/dns-query (8.8.4.4)
    EOT
  }
}