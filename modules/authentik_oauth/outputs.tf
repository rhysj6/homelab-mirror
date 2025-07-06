output "client_id" {
  value     = authentik_provider_oauth2.main.client_id
  sensitive = true
}

output "client_secret" {
  value     = authentik_provider_oauth2.main.client_secret
  sensitive = true
}
