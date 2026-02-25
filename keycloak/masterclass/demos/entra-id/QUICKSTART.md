# Quick Start Guide - Azure Entra ID + Keycloak

## 🚀 Fast Setup (5 minutes)

### Step 1: Run the Setup Script
```bash
./setup.sh
```

This will:
- ✓ Check prerequisites (Azure CLI, Terraform)
- ✓ Authenticate to Azure
- ✓ Create Azure AD app registration
- ✓ Generate client secret

### Step 2: Configure Keycloak

Run this command to see configuration values:
```bash
terraform output -raw keycloak_configuration_guide
```

Or retrieve individual values:
```bash
# Get Client ID
terraform output application_client_id

# Get Client Secret
terraform output -raw application_client_secret

# Get Tenant ID
terraform output tenant_id

# Get Demo User Credentials
terraform output demo_user_principal_name
terraform output -raw demo_user_password
```

### Step 3: Add Identity Provider in Keycloak

1. Open Keycloak Admin Console: http://localhost:8080
2. Login with `admin` / `admin`
3. Select realm: `labrealm`
4. Navigate to: **Identity Providers** > **Add provider** > **OpenID Connect v1.0**
5. Configure (use values from step 3):
   - **Alias**: `azure`
   - **Display Name**: `Microsoft Azure AD`
   - **Authorization URL**: `terraform output authorization_endpoint`
   - **Token URL**: `terraform output token_endpoint`
   - **Client ID**: `terraform output application_client_id`
   - **Client Secret**: `terraform output -raw application_client_secret`
   - **Issuer**: `terraform output issuer`
   - **Default Scopes**: `openid profile email`

### Step 4: Test Login

1. Navigate to Keycloak account console or your test app
2. Click **Microsoft Azure AD** on login page
3. Login with demo user (credentials from step 3)
4. ✓ You should be redirected back to Keycloak with Azure AD account

---

## 📋 Manual Setup (if not using setup.sh)

```bash
# 1. Login to Azure
az login

# 2. Initialize Terraform
terraform init

# 3. Plan changes
terraform plan

# 4. Apply configuration
terraform apply

# 5. Follow steps 2-5 from Fast Setup above
```

---

## 🧹 Cleanup

Remove all Azure resources:
```bash
terraform destroy
```

---

## ⚠️ Troubleshooting

| Error | Solution |
|-------|----------|
| "Application not found" | Grant admin consent in Azure Portal |
| "Invalid redirect_uri" | Check realm name matches in Keycloak |
| "Client authentication failed" | Verify client secret is correct |

---

## 📚 Files Reference

| File | Purpose |
|------|---------|
| `main.tf` | Main Terraform configuration |
| `outputs.tf` | Output values for Keycloak config |
| `variables.tf` | Customizable variables |
| `setup.sh` | Automated setup script |
| `terraform.tfvars.example` | Example configuration file |
| `README.md` | Full documentation |
