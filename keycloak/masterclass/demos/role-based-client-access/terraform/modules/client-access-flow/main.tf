locals {
  allowed_roles = toset(var.allowed_roles)
  role_priority = { for idx, role in sort(tolist(local.allowed_roles)) : role => (idx + 1) * 10 }
  deny_priority = (length(local.allowed_roles) + 1) * 10
}

# ─── Browser flow ─────────────────────────────────────────────────────────────

resource "keycloak_authentication_flow" "browser" {
  realm_id    = var.realm_id
  alias       = "${var.client_id} Browser Flow"
  provider_id = "basic-flow"
}

# ─── Authentication subflow (REQUIRED) ────────────────────────────────────────
# 1:1 copy of the built-in browser flow

resource "keycloak_authentication_subflow" "authentication" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Authentication"
  parent_flow_alias = keycloak_authentication_flow.browser.alias
  provider_id       = "basic-flow"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_execution" "cookie" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.authentication.alias
  authenticator     = "auth-cookie"
  requirement       = "ALTERNATIVE"
  priority          = 10
}

resource "keycloak_authentication_execution" "kerberos" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.authentication.alias
  authenticator     = "auth-spnego"
  requirement       = "DISABLED"
  priority          = 20
}

resource "keycloak_authentication_execution" "idp_redirector" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.authentication.alias
  authenticator     = "identity-provider-redirector"
  requirement       = "ALTERNATIVE"
  priority          = 25
}

# ─── Organization subflow ─────────────────────────────────────────────────────

resource "keycloak_authentication_subflow" "organization" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Organization"
  parent_flow_alias = keycloak_authentication_subflow.authentication.alias
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 26
}

resource "keycloak_authentication_subflow" "organization_conditional" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Browser - Conditional Organization"
  parent_flow_alias = keycloak_authentication_subflow.organization.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 10
}

resource "keycloak_authentication_execution" "organization_user_configured" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.organization_conditional.alias
  authenticator     = "conditional-user-configured"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_execution" "organization" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.organization_conditional.alias
  authenticator     = "organization"
  requirement       = "ALTERNATIVE"
  priority          = 20
}

# ─── Forms subflow ────────────────────────────────────────────────────────────

resource "keycloak_authentication_subflow" "forms" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} forms"
  parent_flow_alias = keycloak_authentication_subflow.authentication.alias
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 30
}

resource "keycloak_authentication_execution" "username_password_form" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.forms.alias
  authenticator     = "auth-username-password-form"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_subflow" "conditional_2fa" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Browser - Conditional 2FA"
  parent_flow_alias = keycloak_authentication_subflow.forms.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 20
}

resource "keycloak_authentication_execution" "conditional_2fa_user_configured" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.conditional_2fa.alias
  authenticator     = "conditional-user-configured"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_execution" "conditional_2fa_credential" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.conditional_2fa.alias
  authenticator     = "conditional-credential"
  requirement       = "REQUIRED"
  priority          = 20
}

resource "keycloak_authentication_execution_config" "conditional_2fa_credential" {
  realm_id     = var.realm_id
  execution_id = keycloak_authentication_execution.conditional_2fa_credential.id
  alias        = "${var.client_id}-browser-conditional-credential"
  config = {
    credentials = "webauthn-passwordless"
  }
}

resource "keycloak_authentication_execution" "otp_form" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.conditional_2fa.alias
  authenticator     = "auth-otp-form"
  requirement       = "ALTERNATIVE"
  priority          = 30
}

resource "keycloak_authentication_execution" "webauthn" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.conditional_2fa.alias
  authenticator     = "webauthn-authenticator"
  requirement       = "DISABLED"
  priority          = 40
}

resource "keycloak_authentication_execution" "recovery_code" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.conditional_2fa.alias
  authenticator     = "auth-recovery-authn-code-form"
  requirement       = "DISABLED"
  priority          = 50
}

# ─── Access Check (CONDITIONAL) ───────────────────────────────────────────────

resource "keycloak_authentication_subflow" "access_check" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Access Check"
  parent_flow_alias = keycloak_authentication_flow.browser.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 20
}

resource "keycloak_authentication_execution" "role_condition" {
  for_each          = local.role_priority
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.access_check.alias
  authenticator     = "conditional-user-role"
  requirement       = "REQUIRED"
  priority          = each.value
}

resource "keycloak_authentication_execution_config" "role_condition" {
  for_each     = local.role_priority
  realm_id     = var.realm_id
  execution_id = keycloak_authentication_execution.role_condition[each.key].id
  alias        = "${var.client_id}-${replace(each.key, ".", "-")}"
  config = {
    condUserRole = each.key
    negate       = "true"
  }
}

resource "keycloak_authentication_execution" "deny" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.access_check.alias
  authenticator     = "deny-access-authenticator"
  requirement       = "REQUIRED"
  priority          = local.deny_priority
}
