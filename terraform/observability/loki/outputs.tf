output "loki_url" {
  description = "The URL for the Loki instance"
  value       = local.loki_url
}

output "loki_password" {
  description = "The password for Loki basic auth"
  value       = random_password.loki_password.result
  sensitive   = true
}
