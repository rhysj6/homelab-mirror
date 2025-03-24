output "secret_name" {
  value = kubernetes_secret_v1.password.metadata[0].name
}

output "service_name" {
  value = "${var.name}-postgres-rw"
}