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

# ─── Kubernetes Identity Provider ─────────────────────────────────────────────
# Validates SA tokens by fetching the K8s JWKS endpoint.
# Keycloak uses its own SA to authenticate to the K8s API server (in-cluster).
#
# The issuer must match the `iss` claim in SA tokens, which reflects the
# API server's --service-account-issuer flag. Discover it with:
#   kubectl create token default | cut -d. -f2 | base64 -d 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['iss'])"

resource "keycloak_kubernetes_identity_provider" "kubernetes" {
  realm  = keycloak_realm.lab.id
  alias  = "kubernetes"
  issuer = var.kubernetes_issuer # adjust to match your cluster's SA token issuer
}

# ─── Client Authentication Flow ───────────────────────────────────────────────
# Replaces the default client-auth flow realm-wide with one that accepts
# federated JWTs (SA tokens) as client credentials.

resource "keycloak_authentication_flow" "federated_client_auth" {
  realm_id    = keycloak_realm.lab.id
  alias       = "clients-federated-jwt"
  provider_id = "client-flow"
}

resource "keycloak_authentication_execution" "federated_jwt" {
  realm_id          = keycloak_realm.lab.id
  parent_flow_alias = keycloak_authentication_flow.federated_client_auth.alias
  authenticator     = "federated-jwt"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_bindings" "auth_bindings" {
  realm_id                   = keycloak_realm.lab.id
  client_authentication_flow = keycloak_authentication_flow.federated_client_auth.alias

  depends_on = [keycloak_authentication_execution.federated_jwt]
}

# ─── Workload Client ──────────────────────────────────────────────────────────
# Identified by the SA's sub claim. No client secret is distributed.
# The SA sub is: system:serviceaccount:<namespace>/<service-account-name>

resource "keycloak_openid_client" "workload_service" {
  realm_id  = keycloak_realm.lab.id
  client_id = "workload-service"
  name      = "Workload Service"
  enabled   = true

  access_type                  = "CONFIDENTIAL"
  service_accounts_enabled     = true
  standard_flow_enabled        = false
  direct_access_grants_enabled = false

  client_authenticator_type = "federated-jwt"
  extra_config = {
    "jwt.credential.issuer" = keycloak_kubernetes_identity_provider.kubernetes.alias
    "jwt.credential.sub"    = "system:serviceaccount:masterclass:demo-workload"
  }

  depends_on = [keycloak_authentication_bindings.auth_bindings]
}
