# universal authentication identity
resource "infisical_identity" "automation_user" {
  name   = "${var.cluster_name}-automation-user"
  role   = "admin"
  org_id = data.infisical_secrets.common.secrets.infisical_org_id.value
}

resource "infisical_identity_universal_auth" "ua-auth" {
  identity_id = infisical_identity.automation_user.id
}

resource "infisical_identity_universal_auth_client_secret" "external-secrets-operator" {
  identity_id = infisical_identity.automation_user.id
  description = "External Secrets Operator Client Secret"

  depends_on = [infisical_identity_universal_auth.ua-auth]
}

resource "infisical_identity_universal_auth_client_secret" "cert-manager" {
  identity_id = infisical_identity.automation_user.id
  description = "Cert Manager Client Secret"

  depends_on = [infisical_identity_universal_auth.ua-auth]
}

resource "kubernetes_cluster_role" "infisical_issuer_approver" {
  metadata {
    name = "infisical-issuer-approver"
  }

  rule {
    api_groups     = ["cert-manager.io"]
    resources      = ["signers"]
    verbs          = ["approve"]
    resource_names = [
      "clusterissuers.infisical-issuer.infisical.com/*"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "infisical_issuer_approver_binding" {
  metadata {
    name = "infisical-issuer-approver-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.infisical_issuer_approver.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager"
    namespace = "cert-manager"
  }
}


resource "kubernetes_secret" "infisical_cluster_issuer" {
  metadata {
    name      = "infisical-cluster-issuer"
    namespace = "cert-manager"
  }
  data = {
    "clientSecret" = infisical_identity_universal_auth_client_secret.cert-manager.client_secret
  }
}

resource "kubernetes_manifest" "infisical_cluster_issuer" {
  manifest = {
    apiVersion = "infisical-issuer.infisical.com/v1alpha1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "infisical"
    }
    spec = {
      url = data.infisical_secrets.common.secrets.infisical_url.value
      projectId = data.infisical_secrets.common.secrets.certs_project_id.value
      certificateTemplateName = "default"
      authentication = {
        universalAuth = {
          clientId = infisical_identity_universal_auth_client_secret.cert-manager.client_id
          secretRef = {
            name = kubernetes_secret.infisical_cluster_issuer.metadata[0].name
            key  = "clientSecret"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_secret.infisical_cluster_issuer]
}
