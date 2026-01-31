data "infisical_secrets" "config" {
  env_slug     = "main"
  workspace_id = "a313cae1-beb5-408e-be83-83fa189863b6"
  folder_path  = "/applications/authentik_config"
}

data "authentik_property_mapping_source_ldap" "ldap_users" {
  managed_list = [
    "goauthentik.io/sources/ldap/ms-givenName",
    "goauthentik.io/sources/ldap/ms-samaccountname",
    "goauthentik.io/sources/ldap/ms-sn",
    "goauthentik.io/sources/ldap/ms-userprincipalname",
    "goauthentik.io/sources/ldap/default-dn-path",
    "goauthentik.io/sources/ldap/default-mail",
    "goauthentik.io/sources/ldap/default-name"
  ]
}

data "authentik_property_mapping_source_ldap" "ldap_groups" {
  managed_list = [
    "goauthentik.io/sources/ldap/default-name",
    "goauthentik.io/sources/ldap/default-mail"
  ]
}

resource "authentik_source_ldap" "active_directory" {
  name = "Active Directory"
  slug = "active-directory"

  server_uri    = "ldaps://${data.infisical_secrets.config.secrets.ldap_domain.value}"
  bind_cn       = data.infisical_secrets.config.secrets.ldap_username.value
  bind_password = data.infisical_secrets.config.secrets.ldap_password.value
  base_dn       = data.infisical_secrets.config.secrets.ldap_base_dn.value

  group_membership_field = "memberOf"
  user_object_filter     = "(&(objectClass=user)(!(objectClass=computer))(memberOf=CN=authentik_access, OU=Global Groups, ${data.infisical_secrets.config.secrets.ldap_base_dn.value}))"
  user_path_template     = "users/%(slug)s"

  property_mappings = data.authentik_property_mapping_source_ldap.ldap_users.ids

  property_mappings_group = data.authentik_property_mapping_source_ldap.ldap_groups.ids
}
