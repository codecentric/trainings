terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.8"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
  url       = "http://localhost:8080"
}

# ─── Realm ────────────────────────────────────────────────────────────────────

resource "keycloak_realm" "lab" {
  realm   = "lab-realm"
  enabled = true
}

# ─── Outline ──────────────────────────────────────────────────────────────────

resource "keycloak_openid_client" "outline" {
  realm_id              = keycloak_realm.lab.id
  client_id             = "outline"
  name                  = "outline"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  client_secret         = "outline-secret"
  standard_flow_enabled = true
  root_url              = "http://localhost:8082"
  valid_redirect_uris   = ["*"]
  web_origins           = ["http://localhost:8082"]

  authentication_flow_binding_overrides {
    browser_id = module.outline_flow.browser_flow_id
  }
}

resource "keycloak_role" "outline_access" {
  realm_id    = keycloak_realm.lab.id
  client_id   = keycloak_openid_client.outline.id
  name        = "access"
  description = "Grants login access to Outline"
}

module "outline_flow" {
  source        = "./modules/client-access-flow"
  realm_id      = keycloak_realm.lab.id
  client_id     = "outline"
  allowed_roles = ["outline.access"]
}

# ─── Nextcloud ────────────────────────────────────────────────────────────────

resource "keycloak_openid_client" "nextcloud" {
  realm_id              = keycloak_realm.lab.id
  client_id             = "nextcloud"
  name                  = "nextcloud"
  enabled               = true
  access_type           = "CONFIDENTIAL"
  client_secret         = "nextcloud-secret"
  standard_flow_enabled = true
  root_url              = "http://localhost:8081"
  valid_redirect_uris   = ["*"]
  web_origins           = ["http://localhost:8081"]

  authentication_flow_binding_overrides {
    browser_id = module.nextcloud_flow.browser_flow_id
  }
}

resource "keycloak_role" "nextcloud_access" {
  realm_id    = keycloak_realm.lab.id
  client_id   = keycloak_openid_client.nextcloud.id
  name        = "access"
  description = "Grants login access to Nextcloud"
}

module "nextcloud_flow" {
  source        = "./modules/client-access-flow"
  realm_id      = keycloak_realm.lab.id
  client_id     = "nextcloud"
  allowed_roles = ["nextcloud.access"]
}

# ─── Users ────────────────────────────────────────────────────────────────────

resource "keycloak_user" "testuser" {
  realm_id       = keycloak_realm.lab.id
  username       = "testuser"
  enabled        = true
  email          = "testuser@example.com"
  first_name     = "Test"
  last_name      = "User"
  email_verified = true

  initial_password {
    value     = "testuser"
    temporary = false
  }
}
