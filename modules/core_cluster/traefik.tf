resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik_crds" {
  chart       = "traefik-crds"
  repository  = "https://traefik.github.io/charts"
  name        = "traefik-crds"
  namespace   = kubernetes_namespace.traefik.id
  version     = "1.9.0"
  max_history = 2
}


resource "helm_release" "traefik" {
  chart       = "traefik"
  repository  = "https://traefik.github.io/charts"
  name        = "traefik"
  namespace   = kubernetes_namespace.traefik.id
  version     = "36.2.0"
  max_history = 2
  depends_on  = [helm_release.traefik_crds, kubernetes_namespace.traefik]
  set_list = [
    {
      name  = "additionalArguments"
      value = ["--serversTransport.insecureSkipVerify=true"]
    }
  ]
  set = [
    {
      name  = "ports.websecure.asDefault"
      value = true
    },
    {
      name  = "ports.websecure.tls.enabled"
      value = true
    },
    {
      name  = "providers.kubernetesCRD.allowExternalNameServices"
      value = true
    },
    {
      name  = "providers.kubernetesIngress.allowExternalNameServices"
      value = true
    },
    {
      name  = "service.annotations.lbipam\\.cilium\\.io/ips"
      value = var.ingress_controller_ip
    },
    {
      name  = "service.spec.externalTrafficPolicy"
      value = "Local"
    }
  ]
}
