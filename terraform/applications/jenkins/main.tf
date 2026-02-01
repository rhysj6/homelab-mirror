locals {
  url = "build.hl.${data.infisical_secrets.common.secrets.domain.value}"
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  chart       = "jenkins"
  repository  = "https://charts.jenkins.io"
  name        = "jenkins"
  namespace   = "jenkins"
  version     = "5.8.134"
  max_history = 2
    values = concat(
    [
      templatefile("${path.module}/main_values.yaml", {
        jenkins_url = local.url
      })
    ],
    [
      for f in fileset(path.module, "values/*.yaml") : file("${path.module}/${f}")
    ]
  )

  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_secret.jenkins-security,
  ]
}

module "authentik" {
  source = "git::https://github.com/rhysj6/homelab.git//terraform/modules/authentik_oauth?ref=main"
  name   = "Jenkins Redcliff"
  slug   = "jenkins-redcliff"
  group  = "Platform"
  url    = "https://${local.url}"
  allowed_redirect_uris = [{
    url           = "https://${local.url}/securityRealm/finishLogin"
    matching_mode = "strict"
  }]
  secure_access = true
}

resource "kubernetes_secret" "jenkins-security" {
  metadata {
    name      = "jenkins-security"
    namespace = "jenkins"
  }
  data = {
    client-id = module.authentik.client_id
    client-secret = module.authentik.client_secret
    authentik-oic-well-known-url = "${data.infisical_secrets.common.secrets.authentik_url.value}/application/o/jenkins-redcliff/.well-known/openid-configuration"
  }
  depends_on = [
    kubernetes_namespace.jenkins,
  ]
}