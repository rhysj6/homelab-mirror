resource "kubernetes_secret_v1" "rfc_secret" {
  metadata {
    name      = "external-dns-rfc-secret"
    namespace = data.kubernetes_namespace.dns.metadata[0].name
  }
  data = {
    secret = data.infisical_secrets.dns.secrets.rfc_secret.value
  }
  type = "Opaque"
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = data.kubernetes_namespace.dns.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.20.0"
  values = [
    yamlencode({
      provider = {
        name = "rfc2136"
      }
      env = [
        {
          name = "RFC2136_TSIG_SECRET"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret_v1.rfc_secret.metadata[0].name
              key  = "secret"
            }
          }
        }
      ]
      extraArgs = concat([
        "--rfc2136-host=${var.dns_server_ip}",
        "--rfc2136-port=53",
        "--rfc2136-tsig-secret=$(RFC2136_TSIG_SECRET)",
        "--rfc2136-tsig-secret-alg=hmac-sha256",
        "--rfc2136-tsig-keyname=externaldns",
      ],
      [for zone in local.dns_zones : "--rfc2136-zone=${zone}"]
      )
    })
  ]
}
