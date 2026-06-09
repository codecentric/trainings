terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.0.0"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
  url       = "http://keycloak:8080"
}

resource "keycloak_realm" "my_realm" {
  realm   = "my-realm"
  enabled = true
}

resource "keycloak_openid_client" "public_client" {
  realm_id  = keycloak_realm.my_realm.id
  client_id = "public-client"
  name      = "Mein Public Client"
  enabled   = true

  # Das macht ihn zum Confidential Client
  access_type = "PUBLIC"

  # Standardeinstellungen für Authorization Code Flow
  standard_flow_enabled      = true
  pkce_code_challenge_method = "S256"

  valid_redirect_uris = [
    "http://localhost:8081/*"
  ]
}

resource "keycloak_openid_client" "confidential_client" {
  realm_id  = keycloak_realm.my_realm.id
  client_id = "confidential-client"
  name      = "Mein Confidential Client"
  enabled   = true

  # Das macht ihn zum Confidential Client
  access_type = "CONFIDENTIAL"

  # Standardeinstellungen für Authorization Code Flow
  standard_flow_enabled = true

  valid_redirect_uris = [
    "http://localhost:8081/*"
  ]
}
