output "application_client_id" {
  description = "The Application (Client) ID for the Keycloak app registration"
  value       = azuread_application.keycloak.client_id
}

output "application_client_secret" {
  description = "The client secret for authenticating to Azure AD (sensitive)"
  value       = azuread_application_password.keycloak.value
  sensitive   = true
}

output "tenant_id" {
  description = "The Azure AD Tenant ID"
  value       = data.azuread_client_config.current.tenant_id
}

output "authorization_endpoint" {
  description = "OAuth2 Authorization endpoint"
  value       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/authorize"
}

output "token_endpoint" {
  description = "OAuth2 Token endpoint"
  value       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/token"
}

output "issuer" {
  description = "OIDC Issuer URL"
  value       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
}

output "jwks_uri" {
  description = "JSON Web Key Set URI"
  value       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/discovery/v2.0/keys"
}

output "discovery_endpoint" {
  description = "OpenID Connect Discovery endpoint (use this in Keycloak for auto-configuration)"
  value       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0/.well-known/openid-configuration"
}

output "keycloak_configuration_guide" {
  description = "Quick reference for configuring Keycloak"
  value       = <<-EOT

  ============================================
  Keycloak Azure AD (Entra ID) Configuration
  ============================================

  1. In Keycloak Admin Console:
     - Navigate to: Identity Providers > Add provider > OpenID Connect v1.0

  2. Use these values:
     Alias:                 azure
     Display Name:          Microsoft Azure AD
     Discovery Endpoint:    https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0/.well-known/openid-configuration

     OR manually configure:
     Authorization URL:     https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/authorize
     Token URL:             https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/token
     Issuer:                https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0

     Client ID:             ${azuread_application.keycloak.client_id}
     Client Secret:         <retrieve with: terraform output -raw application_client_secret>
     Default Scopes:        openid profile email

  ============================================
  EOT
}
