terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.0"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
  url       = "http://localhost:8080"
}

resource "keycloak_realm" "mcp_demo" {
  realm        = "mcp-demo"
  ssl_required = "external"
}

resource "keycloak_openid_client_scope" "mcp_tools" {
  realm_id               = keycloak_realm.mcp_demo.id
  name                   = "mcp:tools"
  description            = "Access to MCP tools"
  include_in_token_scope = true
  consent_screen_text    = "Access MCP tools on your behalf"
}

resource "keycloak_realm_default_client_scopes" "default_scopes" {
  realm_id = keycloak_realm.mcp_demo.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    "acr",
    "basic",
  ]
}

resource "keycloak_realm_optional_client_scopes" "optional_scopes" {
  realm_id = keycloak_realm.mcp_demo.id

  optional_scopes = [
    "offline_access",
    "address",
    "phone",
    "microprofile-jwt",
    "organization",
    keycloak_openid_client_scope.mcp_tools.name,
  ]
}

resource "keycloak_user" "testuser" {
  realm_id   = keycloak_realm.mcp_demo.id
  username   = "testuser"
  email      = "testuser@example.com"
  first_name = "Test"
  last_name  = "User"

  initial_password {
    value     = "testuser"
    temporary = false
  }
}

resource "keycloak_realm_client_policy_profile" "cimd_profile" {
  realm_id    = keycloak_realm.mcp_demo.id
  name        = "cimd-profile"
  description = "Enforces Client ID Metadata Document validation for MCP clients"

  executor {
    name = "client-id-metadata-document"
    configuration = {
      "cimd-allow-http-scheme"         = "false"
      "cimd-allow-permitted-domains"   = jsonencode(["claude.ai", "localhost", "127.0.0.1"])
      "cimd-restrict-same-domain"      = "false"
      "only-allow-confidential-client" = "false"
    }
  }

  executor {
    name = "pkce-enforcer"
    configuration = {
      "auto-configure" = true
    }
  }
}

# Fires on PRE_AUTHORIZATION_REQUEST — validates CIMD metadata document
resource "keycloak_realm_client_policy_profile_policy" "cimd_policy" {
  realm_id    = keycloak_realm.mcp_demo.id
  name        = "cimd-policy"
  description = "Apply CIMD validation to clients using a URL as client_id"
  profiles    = [keycloak_realm_client_policy_profile.cimd_profile.name]

  condition {
    name = "client-id-uri"
    configuration = {
      "client-id-uri-scheme"                  = jsonencode(["https"])
      "client-id-uri-allow-permitted-domains" = jsonencode(["claude.ai"])
    }
  }
}
