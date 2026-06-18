variable "realm_id" {
  type        = string
  description = "The ID of the realm this flow lives in."
}

variable "client_id" {
  type        = string
  description = "The OIDC client_id string (e.g. 'outline'). Used for flow alias naming."
}

variable "allowed_roles" {
  type        = list(string)
  description = "Roles that grant login access, in Keycloak 'clientId.roleName' or plain 'roleName' format. At least one required."

  validation {
    condition     = length(var.allowed_roles) > 0
    error_message = "allowed_roles must contain at least one role."
  }
}
