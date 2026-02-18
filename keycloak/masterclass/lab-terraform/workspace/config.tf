terraform {
 required_providers {
   keycloak = {
     source = "keycloak/keycloak"
     version = "5.0.0"
   }
 }
}

provider "keycloak" {
 client_id     = "admin-cli"
 username      = "admin"
 password      = "admin"
 url           = "http://keycloak:8080"
}

resource "keycloak_realm" "my_realm" {
 realm   = "my-realm"
 enabled = true
}

resource "keycloak_openid_client" "confidential_client" {
  realm_id  = keycloak_realm.my_realm.id
  client_id = "confidential-client"
  name      = "Mein Confidential Client"
  enabled   = true

  # Das macht ihn zum Confidential Client
  access_type = "CONFIDENTIAL"

  # Standardeinstellungen für Authorization Code Flow
  standard_flow_enabled        = true
  direct_access_grants_enabled = true

  valid_redirect_uris = [
    "http://localhost:8081/*"
  ]
}
