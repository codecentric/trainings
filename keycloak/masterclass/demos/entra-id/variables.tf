variable "keycloak_base_url" {
  description = "Base URL for your Keycloak instance"
  type        = string
  default     = "http://localhost:8080"
}

variable "keycloak_realm" {
  description = "Keycloak realm name for Azure AD integration"
  type        = string
  default     = "labrealm"
}
