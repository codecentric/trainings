output "browser_flow_id" {
  value       = keycloak_authentication_flow.browser.id
  description = "ID of the custom browser flow. Pass to the client's authentication_flow_binding_overrides.browser_id."
}
