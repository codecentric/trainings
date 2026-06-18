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

# ─── Cookie subflow ───────────────────────────────────────────────────────────

resource "keycloak_authentication_subflow" "cookie" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Cookie"
  parent_flow_alias = keycloak_authentication_flow.browser.alias
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 10
}

resource "keycloak_authentication_execution" "cookie" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.cookie.alias
  authenticator     = "auth-cookie"
  requirement       = "ALTERNATIVE"
  priority          = 10
}

resource "keycloak_authentication_subflow" "cookie_access_check" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Cookie Access Check"
  parent_flow_alias = keycloak_authentication_subflow.cookie.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 20
}

resource "keycloak_authentication_execution" "cookie_role_condition" {
  for_each          = local.role_priority
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.cookie_access_check.alias
  authenticator     = "conditional-user-role"
  requirement       = "REQUIRED"
  priority          = each.value
}

resource "keycloak_authentication_execution_config" "cookie_role_condition" {
  for_each     = local.role_priority
  realm_id     = var.realm_id
  execution_id = keycloak_authentication_execution.cookie_role_condition[each.key].id
  alias        = "${var.client_id}-cookie-${replace(each.key, ".", "-")}"
  config = {
    condUserRole = each.key
    negate = "true"
  }
}

resource "keycloak_authentication_execution" "cookie_deny" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.cookie_access_check.alias
  authenticator     = "deny-access-authenticator"
  requirement       = "REQUIRED"
  priority          = local.deny_priority
}

# ─── Kerberos subflow ─────────────────────────────────────────────────────────

resource "keycloak_authentication_subflow" "kerberos" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Kerberos"
  parent_flow_alias = keycloak_authentication_flow.browser.alias
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 20
}

resource "keycloak_authentication_execution" "kerberos" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.kerberos.alias
  authenticator     = "auth-spnego"
  requirement       = "ALTERNATIVE"
  priority          = 10
}

resource "keycloak_authentication_subflow" "kerberos_access_check" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Kerberos Access Check"
  parent_flow_alias = keycloak_authentication_subflow.kerberos.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 20
}

resource "keycloak_authentication_execution" "kerberos_role_condition" {
  for_each          = local.role_priority
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.kerberos_access_check.alias
  authenticator     = "conditional-user-role"
  requirement       = "REQUIRED"
  priority          = each.value
}

resource "keycloak_authentication_execution_config" "kerberos_role_condition" {
  for_each     = local.role_priority
  realm_id     = var.realm_id
  execution_id = keycloak_authentication_execution.kerberos_role_condition[each.key].id
  alias        = "${var.client_id}-kerberos-${replace(each.key, ".", "-")}"
  config = {
    condUserRole = each.key
    negate = "true"
  }
}

resource "keycloak_authentication_execution" "kerberos_deny" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.kerberos_access_check.alias
  authenticator     = "deny-access-authenticator"
  requirement       = "REQUIRED"
  priority          = local.deny_priority
}

# ─── Identity Provider subflow ────────────────────────────────────────────────

resource "keycloak_authentication_subflow" "idp" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Identity Provider"
  parent_flow_alias = keycloak_authentication_flow.browser.alias
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 30
}

resource "keycloak_authentication_execution" "idp_redirector" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.idp.alias
  authenticator     = "identity-provider-redirector"
  requirement       = "ALTERNATIVE"
  priority          = 10
}

resource "keycloak_authentication_subflow" "idp_access_check" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} IDP Access Check"
  parent_flow_alias = keycloak_authentication_subflow.idp.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 20
}

resource "keycloak_authentication_execution" "idp_role_condition" {
  for_each          = local.role_priority
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.idp_access_check.alias
  authenticator     = "conditional-user-role"
  requirement       = "REQUIRED"
  priority          = each.value
}

resource "keycloak_authentication_execution_config" "idp_role_condition" {
  for_each     = local.role_priority
  realm_id     = var.realm_id
  execution_id = keycloak_authentication_execution.idp_role_condition[each.key].id
  alias        = "${var.client_id}-idp-${replace(each.key, ".", "-")}"
  config = {
    condUserRole = each.key
    negate = "true"
  }
}

resource "keycloak_authentication_execution" "idp_deny" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.idp_access_check.alias
  authenticator     = "deny-access-authenticator"
  requirement       = "REQUIRED"
  priority          = local.deny_priority
}

# ─── Organization subflow ─────────────────────────────────────────────────────

resource "keycloak_authentication_subflow" "organization" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Organization"
  parent_flow_alias = keycloak_authentication_flow.browser.alias
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 40
}

resource "keycloak_authentication_subflow" "organization_conditional" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Browser - Conditional Organization"
  parent_flow_alias = keycloak_authentication_subflow.organization.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 10
}

resource "keycloak_authentication_execution" "organization_condition" {
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

resource "keycloak_authentication_subflow" "organization_access_check" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} Organization Access Check"
  parent_flow_alias = keycloak_authentication_subflow.organization.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 20
}

resource "keycloak_authentication_execution" "organization_role_condition" {
  for_each          = local.role_priority
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.organization_access_check.alias
  authenticator     = "conditional-user-role"
  requirement       = "REQUIRED"
  priority          = each.value
}

resource "keycloak_authentication_execution_config" "organization_role_condition" {
  for_each     = local.role_priority
  realm_id     = var.realm_id
  execution_id = keycloak_authentication_execution.organization_role_condition[each.key].id
  alias        = "${var.client_id}-organization-${replace(each.key, ".", "-")}"
  config = {
    condUserRole = each.key
    negate = "true"
  }
}

resource "keycloak_authentication_execution" "organization_deny" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.organization_access_check.alias
  authenticator     = "deny-access-authenticator"
  requirement       = "REQUIRED"
  priority          = local.deny_priority
}

# ─── Username/Password subflow ────────────────────────────────────────────────

resource "keycloak_authentication_subflow" "userpass" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} UsernamePassword"
  parent_flow_alias = keycloak_authentication_flow.browser.alias
  provider_id       = "basic-flow"
  requirement       = "ALTERNATIVE"
  priority          = 50
}

resource "keycloak_authentication_execution" "userpass_form" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass.alias
  authenticator     = "auth-username-password-form"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_subflow" "userpass_otp" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} OTP"
  parent_flow_alias = keycloak_authentication_subflow.userpass.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 20
}

resource "keycloak_authentication_execution" "userpass_otp_condition_configured" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass_otp.alias
  authenticator     = "conditional-user-configured"
  requirement       = "REQUIRED"
  priority          = 10
}

resource "keycloak_authentication_execution" "userpass_otp_condition_credential" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass_otp.alias
  authenticator     = "conditional-credential"
  requirement       = "REQUIRED"
  priority          = 20
}

resource "keycloak_authentication_execution" "userpass_otp_form" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass_otp.alias
  authenticator     = "auth-otp-form"
  requirement       = "ALTERNATIVE"
  priority          = 30
}

resource "keycloak_authentication_execution" "userpass_webauthn" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass_otp.alias
  authenticator     = "webauthn-authenticator"
  requirement       = "DISABLED"
  priority          = 40
}

resource "keycloak_authentication_execution" "userpass_recovery_code" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass_otp.alias
  authenticator     = "auth-recovery-authn-code-form"
  requirement       = "DISABLED"
  priority          = 50
}

resource "keycloak_authentication_subflow" "userpass_access_check" {
  realm_id          = var.realm_id
  alias             = "${var.client_id} UserPass Access Check"
  parent_flow_alias = keycloak_authentication_subflow.userpass.alias
  provider_id       = "basic-flow"
  requirement       = "CONDITIONAL"
  priority          = 30
}

resource "keycloak_authentication_execution" "userpass_role_condition" {
  for_each          = local.role_priority
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass_access_check.alias
  authenticator     = "conditional-user-role"
  requirement       = "REQUIRED"
  priority          = each.value
}

resource "keycloak_authentication_execution_config" "userpass_role_condition" {
  for_each     = local.role_priority
  realm_id     = var.realm_id
  execution_id = keycloak_authentication_execution.userpass_role_condition[each.key].id
  alias        = "${var.client_id}-userpass-${replace(each.key, ".", "-")}"
  config = {
    condUserRole = each.key
    negate = "true"
  }
}

resource "keycloak_authentication_execution" "userpass_deny" {
  realm_id          = var.realm_id
  parent_flow_alias = keycloak_authentication_subflow.userpass_access_check.alias
  authenticator     = "deny-access-authenticator"
  requirement       = "REQUIRED"
  priority          = local.deny_priority
}
