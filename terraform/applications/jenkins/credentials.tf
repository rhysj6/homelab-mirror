
resource "kubernetes_secret_v1" "github" {
  metadata {
    name      = "github"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      "jenkins.io/credentials-type" = "usernamePassword"
    }
    annotations = {
        "jenkins.io/credentials-description" = "GitHub PAT"
    }
  }

  data = {
    username = data.infisical_secrets.jenkins.secrets.github_username.value
    password = data.infisical_secrets.jenkins.secrets.github_pat.value
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "dockerhub" {
  metadata {
    name      = "dockerhub"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      "jenkins.io/credentials-type" = "usernamePassword"
    }
    annotations = {
        "jenkins.io/credentials-description" = "DockerHub PAT"
    }
  }

  data = {
    username = data.infisical_secrets.jenkins.secrets.dockerhub_username.value
    password = data.infisical_secrets.jenkins.secrets.dockerhub_pat.value
  }

  type = "Opaque"
}


resource "kubernetes_secret_v1" "initial_setup_private_key" {
  metadata {
    name      = "initial-setup-private-key"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      "jenkins.io/credentials-type" = "basicSSHUserPrivateKey"
    }
    annotations = {
        "jenkins.io/credentials-description" = "Initial Setup Ansible Private Key"
    }
  }

  data = {
    username   = data.infisical_secrets.jenkins.secrets.ansible_initial_setup_username.value
    privateKey = data.infisical_secrets.jenkins.secrets.ansible_initial_setup_private_key.value
  }

  type = "Opaque"
}
