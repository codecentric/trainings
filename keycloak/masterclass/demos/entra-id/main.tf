terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.0"
    }
  }
}

provider "azuread" {
  # Authentication via Azure CLI is recommended for local development
  # Run: az login
}

# Get current Azure AD configuration
data "azuread_client_config" "current" {}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create an Azure AD Application for Keycloak OIDC integration
resource "azuread_application" "keycloak" {
  display_name     = "Keycloak Identity Broker - ${random_string.suffix.result}"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  # Configure redirect URIs for Keycloak
  web {
    redirect_uris = [
      "http://localhost:8080/realms/labrealm/broker/azure/endpoint",
      "http://localhost:8080/realms/master/broker/azure/endpoint"
    ]

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  # Request required API permissions for user profile information
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    # OpenID permissions
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }

    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
      type = "Scope"
    }

    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
      type = "Scope"
    }

    # User.Read to access user profile
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }

  # Add optional claims to include in ID token
  optional_claims {
    id_token {
      name      = "email"
      essential = true
    }

    id_token {
      name      = "family_name"
      essential = false
    }

    id_token {
      name      = "given_name"
      essential = false
    }
  }
}

# Create a service principal for the application
resource "azuread_service_principal" "keycloak" {
  client_id = azuread_application.keycloak.client_id
  owners    = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise = true
  }

  # Ensure service principal is created after password
  # This means during destroy, password is deleted first (reverse order)
  depends_on = [azuread_application_password.keycloak]
}

# Generate a client secret for the application
resource "azuread_application_password" "keycloak" {
  display_name   = "Keycloak Integration Secret"
  application_id = azuread_application.keycloak.id

  # Secret valid for 2 years
  end_date = timeadd(timestamp(), "17520h") # 730 days
}

# Get default domain information
data "azuread_domains" "default" {
  only_initial = true
}
