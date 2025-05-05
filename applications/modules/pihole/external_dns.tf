resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = kubernetes_namespace.dns.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.16.0"
  values = [
    yamlencode({
      provider = {
        name = "pihole"
      }
      env = [
        {
          name = "EXTERNAL_DNS_PIHOLE_PASSWORD"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_secret_v1.password.metadata[0].name
              key  = "password"
            }
          }
        }
      ]
      extraArgs = [
        "--pihole-server=http://pihole-web.dns.svc.cluster.local"
      ]
    })
  ]
}
