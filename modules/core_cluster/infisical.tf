# universal authentication identity
resource "infisical_identity" "automation_user" {
  name   = "${var.cluster_name}-automation-user"
  role   = "admin"
  org_id = data.infisical_secrets.metadata.secrets["infisical_org_id"].value
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

resource "helm_release" "infisical_pki_operator" {
  chart       = "infisical-pki-issuer"
  repository  = "https://dl.cloudsmith.io/public/infisical/helm-charts/helm/charts"
  name        = "infisical-pki-issuer"
  namespace   = kubernetes_namespace.cert_manager.id
  version     = "v0.1.0"
  max_history = 2
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
