# Azure Entra ID Integration with Keycloak - Demo

This Terraform project creates a minimal Azure Entra ID (formerly Azure Active Directory) setup for integrating with a locally running Keycloak instance as an Identity Provider.

## Prerequisites

- **Azure Subscription**: An active Azure subscription
- **Azure CLI**: Installed and configured ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- **Terraform**: Version 1.0 or higher ([Download](https://www.terraform.io/downloads))
- **Keycloak**: Running locally on port 8080 (see parent labs for setup)
- **Azure AD Permissions**: Application Developer role or higher (see [PERMISSIONS.md](PERMISSIONS.md) for details)

## What This Demo Creates

This Terraform configuration provisions:

1. **Azure AD Application Registration** - Configured as an OpenID Connect provider
2. **Service Principal** - Enterprise application for the registration
3. **Client Secret** - For authenticating Keycloak to Azure AD
5. **API Permissions** - Required Microsoft Graph permissions for user profile access

## Setup Instructions

### 1. Authenticate to Azure

```bash
# Login to Azure
az login

# Verify your subscription
az account show

# (Optional) Set a specific subscription if you have multiple
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Initialize Terraform

```bash
cd keycloak/masterclass/demos/entra-id

# Initialize Terraform providers
terraform init
```

### 3. Review the Plan

```bash
# See what will be created
terraform plan
```

### 4. Apply the Configuration

```bash
# Create the Azure resources
terraform apply
```

Review the planned changes and type `yes` to confirm.

### 5. Retrieve Configuration Values

After successful deployment, retrieve the values needed for Keycloak:

```bash
# Get Client ID
terraform output application_client_id

# Get Client Secret (sensitive)
terraform output -raw application_client_secret

# Get Tenant ID
terraform output tenant_id

# Get all endpoints
terraform output authorization_endpoint
terraform output token_endpoint
terraform output issuer

# Or see the full configuration guide
terraform output -raw keycloak_configuration_guide
```

## Configuring Keycloak

### Step 1: Add Azure AD as Identity Provider

1. Open Keycloak Admin Console: http://localhost:8080
2. Login with `admin` / `admin`
3. Select your realm (e.g., `labrealm` or create a new one)
4. Navigate to: **Identity Providers** > **Add provider** > **OpenID Connect v1.0**

### Step 2: Configure Provider Settings

Use the values from Terraform outputs:

| Field | Value |
|-------|-------|
| **Alias** | `azure` |
| **Display Name** | `Microsoft Azure AD` |
| **Authorization URL** | From `terraform output authorization_endpoint` |
| **Token URL** | From `terraform output token_endpoint` |
| **Client ID** | From `terraform output application_client_id` |
| **Client Secret** | From `terraform output -raw application_client_secret` |
| **Issuer** | From `terraform output issuer` |
| **Default Scopes** | `openid profile email` |

### Step 3: Grant Admin Consent (Required)

The Azure AD application requires admin consent to access user profile information:

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to: **App registrations** > **Keycloak Identity Broker-XXXXXX**
3. Click: **API permissions** > **Grant admin consent for [Your Directory]**
4. Confirm the consent

### Step 4: Test the Integration

1. In Keycloak, create a test application or use the account console
2. Navigate to the login page
3. Click on **Microsoft Azure AD** button
4. Login in Microsoft Azure AD. You should then see a registration page of Keycloak

## Architecture Overview

```
┌─────────────────┐         OIDC Flow          ┌──────────────────┐
│                 │◄──────────────────────────►│                  │
│   Keycloak      │                             │   Azure Entra   │
│   (Localhost)   │  Authorization Code Flow   │   ID (Cloud)    │
│                 │                             │                  │
└─────────────────┘                             └──────────────────┘
        │                                                │
        │                                                │
        ▼                                                ▼
   User Accounts                                  Azure AD Users
   (Local Realm)                                  
```

## Customization

### Change Redirect URIs

Edit `main.tf` and modify the `web.redirect_uris` block:

```hcl
web {
  redirect_uris = [
    "http://localhost:8080/realms/YOUR_REALM/broker/azure/endpoint",
  ]
}
```

### Adjust Token Lifetime

Modify the secret expiration in `main.tf`:

```hcl
resource "azuread_application_password" "keycloak" {
  # Change from 2 years to your preferred duration
  end_date = timeadd(timestamp(), "8760h") # 1 year
}
```

## Cleanup

To remove all Azure resources created by this demo:

```bash
terraform destroy
```

Type `yes` to confirm deletion.

## Troubleshooting

### Issue: "AADSTS700016: Application not found"

**Solution**: Ensure you've granted admin consent in Azure Portal (Step 3 above).

### Issue: "Invalid redirect_uri"

**Solution**: Verify that the redirect URI in Keycloak matches exactly what's configured in Azure AD. The realm name is case-sensitive.

### Issue: "Client authentication failed"

**Solution**: Double-check that you're using the correct client secret from `terraform output -raw application_client_secret`.

## Security Notes

- **Client Secret**: The client secret is sensitive. In production, store it securely (e.g., Azure Key Vault, Keycloak vault)
- **Redirect URIs**: Localhost URIs are only for development. Use HTTPS URLs in production
- **Token Lifetime**: Secrets expire after 2 years by default. Set up rotation before expiration

## Additional Resources

- [Keycloak Identity Brokering Documentation](https://www.keycloak.org/docs/latest/server_admin/#_identity_broker)
- [Azure AD OpenID Connect](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc)
- [Microsoft Graph Permissions Reference](https://docs.microsoft.com/en-us/graph/permissions-reference)

## Support

This is demo/training material. For Keycloak masterclass support, contact your codecentric instructor.
