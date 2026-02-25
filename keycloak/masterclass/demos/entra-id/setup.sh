#!/bin/bash
set -e

echo "================================================"
echo "Azure Entra ID + Keycloak Demo Setup"
echo "================================================"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi
echo "✓ Azure CLI found"

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install: https://www.terraform.io/downloads"
    exit 1
fi
echo "✓ Terraform found"

# Check Azure login
echo ""
echo "Checking Azure authentication..."
if ! az account show &> /dev/null; then
    echo "⚠️  Not logged into Azure. Running 'az login'..."
    az login
else
    echo "✓ Already authenticated to Azure"
    echo ""
    echo "Current Azure subscription:"
    az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" -o table
fi

echo ""
read -p "Continue with this subscription? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please run 'az account set --subscription YOUR_SUBSCRIPTION_ID' to change subscription"
    exit 1
fi

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

# Plan
echo ""
echo "Creating Terraform plan..."
terraform plan -out=tfplan

# Confirm apply
echo ""
read -p "Apply this plan and create Azure resources? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Apply
echo ""
echo "Creating Azure resources..."
terraform apply tfplan

# Output configuration
echo ""
echo "================================================"
echo "✓ Azure resources created successfully!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Grant admin consent in Azure Portal:"
echo "   - Go to: https://portal.azure.com"
echo "   - Navigate to: App registrations"
echo "   - Find: 'Keycloak Identity Broker-*'"
echo "   - Click: API permissions > Grant admin consent"
echo ""
echo "2. View Keycloak configuration guide:"
echo "   terraform output -raw keycloak_configuration_guide"
echo ""
echo "3. Retrieve sensitive values when needed:"
echo "   terraform output -raw application_client_secret"
echo "   terraform output -raw demo_user_password"
echo ""
echo "================================================"
