# Lab Security Hardening - Solution (Trainer Reference)

## Summary Table

| # | Issue | Location | Severity |
|---|-------|----------|----------|
| 1 | SSL Required = none | Realm Settings > General | Critical |
| 2 | Brute Force Protection disabled | Realm Settings > Security Defenses | High |
| 3 | Weak Password Hashing (1 iteration) | Authentication > Policies > Password Policy | Critical |
| 4 | Login Events disabled | Realm Settings > Events | Medium |
| 5 | Admin Events disabled | Realm Settings > Events | Medium |
| 6 | Access Token Lifetime 60 min | Realm Settings > Tokens | High |
| 7 | SSO Session Idle 24 hours | Realm Settings > Sessions | Medium |
| 8 | SSO Session Max 30 days | Realm Settings > Sessions | High |
| 9 | Refresh Token Revocation disabled | Realm Settings > Tokens | Medium |
| 10 | Self-Registration without Email Verification | Realm Settings > Login / Email | Medium |
| 11 | All Security Headers empty | Realm Settings > Security Defenses > Headers | High |
| 12 | webapp: Wildcard Redirect URI | Clients > webapp | Critical |
| 13 | webapp: Implicit Flow + Direct Access Grants + offline_access | Clients > webapp | High |
| 14 | spa-app: No PKCE, broad Redirect URIs, Direct Access Grants on public client | Clients > spa-app | Critical |
| 15 | spa-app: Standard Flow disabled, only Implicit Flow | Clients > spa-app | High |
| 16 | service-account-client: realm-admin role + weak secret | Clients > service-account-client | Critical |
| 17 | realmadmin: Admin user in application realm | Users > realmadmin | High |
| 18 | CORS wide open on all clients | Clients > webapp / spa-app | High |
| 19 | Offline Session Max Lifespan 1 year | Realm Settings > Sessions | High |
| 20 | No MFA/OTP configured | Authentication > Required Actions / Flows | High |

---

## Detailed Findings

### 1. SSL Required = none

- **Location:** Realm Settings > General > Require SSL
- **Finding:** `Require SSL` is set to `None`. All communication happens unencrypted.
- **Risk:** Credentials and tokens are transmitted in plaintext. Man-in-the-middle attacks can intercept sensitive data.
- **Fix:** Set to `External requests` (minimum) or `All requests` for production.

### 2. Brute Force Protection disabled

- **Location:** Realm Settings > Security Defenses > Brute Force Detection
- **Finding:** Brute Force Detection is disabled.
- **Risk:** Attackers can perform unlimited login attempts to guess passwords.
- **Fix:** Enable Brute Force Detection. Configure `Max Login Failures` (e.g., 5), `Wait Increment` and `Max Wait` appropriately.

### 3. Weak Password Hashing (1 iteration)

- **Location:** Authentication > Policies > Password Policy
- **Finding:** The password policy only contains `hashIterations(1)`. This reduces PBKDF2 hashing to a single iteration (Keycloak default: 210,000). Additionally, no other password policies are configured - no minimum length, complexity, or history requirements.
- **Risk:** Two problems in one: (1) If the database is compromised, password hashes can be cracked almost instantly. With 210,000 iterations, brute-forcing a single hash takes significant time. With 1 iteration, millions of guesses per second are possible. (2) Users can set any password, including `1` or `password`.
- **Fix:** Remove `hashIterations(1)` (or set to at least 210,000). Add policies: minimum length (8+), uppercase, lowercase, digits, special characters, not username, password history.

### 4. Login Events disabled

- **Location:** Realm Settings > Events > User events settings
- **Finding:** `Save events` is disabled.
- **Risk:** No audit trail for login attempts, failed logins, or suspicious activity. Security incidents cannot be investigated.
- **Fix:** Enable `Save events` and set an appropriate expiration (e.g., 30 days). Include error events.

### 5. Admin Events disabled

- **Location:** Realm Settings > Events > Admin events settings
- **Finding:** `Save events` for admin events is disabled.
- **Risk:** No audit trail for administrative changes. Unauthorized configuration changes go unnoticed.
- **Fix:** Enable admin event logging. Consider enabling `Include representation` for full change tracking.

### 6. Access Token Lifetime 60 minutes

- **Location:** Realm Settings > Tokens > Access Token Lifespan
- **Finding:** Access Token Lifespan is set to 60 minutes (default is 5 minutes).
- **Risk:** If a token is stolen, the attacker has a 60-minute window to use it. Access tokens are typically not revocable.
- **Fix:** Set to 5 minutes or less. Use refresh tokens for longer sessions.

### 7. SSO Session Idle 24 hours

- **Location:** Realm Settings > Sessions > SSO Session Idle
- **Finding:** SSO Session Idle Timeout is set to 24 hours (default is 30 minutes).
- **Risk:** Unattended sessions remain valid for a full day. If a user walks away from their computer, the session stays active.
- **Fix:** Set to 30 minutes or less, depending on security requirements.

### 8. SSO Session Max 30 days

- **Location:** Realm Settings > Sessions > SSO Session Max
- **Finding:** SSO Session Max Lifespan is set to 30 days (default is 10 hours).
- **Risk:** Even actively used sessions remain valid for an entire month without requiring re-authentication. Combined with the 24h idle timeout, a stolen session cookie gives an attacker up to 30 days of access. The Max timeout is the absolute upper limit - the Idle timeout only helps if the attacker stops using the session.
- **Fix:** Set to 8-10 hours for typical business applications. This forces daily re-authentication regardless of activity.

### 9. Refresh Token Revocation disabled

- **Location:** Realm Settings > Tokens > Revoke Refresh Token
- **Finding:** `Revoke Refresh Token` is disabled.
- **Risk:** Refresh tokens can be reused indefinitely. A stolen refresh token grants permanent access.
- **Fix:** Enable `Revoke Refresh Token`. Set `Refresh Token Max Reuse` to 0 for one-time use (rotation).

### 10. Self-Registration without Email Verification

- **Location:** Realm Settings > Login (`User registration` enabled) / Realm Settings > Login (`Verify email` disabled)
- **Finding:** User self-registration is enabled, but email verification is disabled.
- **Risk:** Anyone can register accounts with fake email addresses. Enables spam accounts, impersonation, and abuse.
- **Fix:** Either disable self-registration or enable `Verify email` to ensure valid email ownership.

### 11. All Security Headers empty

- **Location:** Realm Settings > Security Defenses > Headers
- **Finding:** All browser security headers are set to empty strings.
- **Risk:** Missing protection against clickjacking (X-Frame-Options), MIME sniffing (X-Content-Type-Options), XSS (X-XSS-Protection, CSP), and more.
- **Fix:** Restore Keycloak defaults:
  - `X-Frame-Options: SAMEORIGIN`
  - `Content-Security-Policy: frame-src 'self'; frame-ancestors 'self'; object-src 'none';`
  - `X-Content-Type-Options: nosniff`
  - `X-XSS-Protection: 1; mode=block`
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
  - `Referrer-Policy: no-referrer`
  - `X-Robots-Tag: none`

### 12. webapp: Wildcard Redirect URI

- **Location:** Clients > webapp > Settings > Valid Redirect URIs
- **Finding:** Redirect URI is set to `*` (wildcard).
- **Risk:** An attacker can redirect the authorization code or token to any URL they control (Open Redirect / Authorization Code Interception).
- **Fix:** Set specific, exact redirect URIs (e.g., `https://myapp.example.com/callback`).

### 13. webapp: Implicit Flow + Direct Access Grants + offline_access as Default Scope

- **Location:** Clients > webapp > Settings / Client Scopes
- **Finding:** Implicit Flow and Direct Access Grants are enabled. `offline_access` is a default scope.
- **Risk:**
  - Implicit Flow exposes tokens in the URL fragment (browser history, referrer headers).
  - Direct Access Grants (ROPC) means the application handles user credentials directly.
  - `offline_access` as default scope grants long-lived refresh tokens to every session automatically.
- **Fix:** Disable Implicit Flow and Direct Access Grants. Move `offline_access` to optional scopes. Use Authorization Code Flow with PKCE.

### 14. spa-app: No PKCE, broad Redirect URIs, Direct Access Grants on public client

- **Location:** Clients > spa-app > Settings / Advanced
- **Finding:** PKCE is not enforced (`pkce.code.challenge.method` is empty), redirect URIs accept any HTTP URL (`http://*`), and Direct Access Grants (ROPC) is enabled on a public client.
- **Risk:**
  - Without PKCE, authorization codes can be intercepted (especially critical for public clients/SPAs).
  - `http://*` accepts any HTTP redirect, enabling token theft via malicious sites.
  - Direct Access Grants (ROPC = Resource Owner Password Credentials) on a public client means any JavaScript can send username/password directly to Keycloak.
- **Fix:** Set `pkce.code.challenge.method` to `S256`. Restrict redirect URIs to specific origins. Disable Direct Access Grants.

### 15. spa-app: Standard Flow disabled, only Implicit Flow

- **Location:** Clients > spa-app > Settings
- **Finding:** Standard Flow (Authorization Code) is disabled. Only Implicit Flow is enabled.
- **Risk:** Implicit Flow is deprecated for SPAs (OAuth 2.1). Tokens are exposed in URL fragments, vulnerable to token leakage via browser history, logs, and referrer headers.
- **Fix:** Enable Standard Flow, disable Implicit Flow. Use Authorization Code Flow with PKCE (the recommended flow for SPAs).

### 16. service-account-client: realm-admin role + weak secret

- **Location:** Clients > service-account-client > Credentials / Service Account Roles
- **Finding:** The client secret is `password`. The service account has the `realm-admin` role assigned.
- **Risk:**
  - A trivially guessable client secret means anyone can obtain tokens for this client.
  - With `realm-admin`, this client has full administrative access to the entire realm (create/delete users, modify clients, change settings).
  - Combined: anyone who guesses the secret gains full realm admin access.
- **Fix:** Generate a strong, random client secret. Remove `realm-admin` role. Assign only the minimum required roles following the principle of least privilege.

### 17. realmadmin: Admin user in application realm

- **Location:** Users > realmadmin > Role Mappings
- **Finding:** A user `realmadmin` exists with the `realm-admin` client role from `realm-management`.
- **Risk:** An application realm user has full administrative access. If the account is compromised (weak password `admin123`), the attacker can modify the entire realm configuration.
- **Fix:** Administrative access should be managed through the `master` realm only. Remove the `realm-admin` role from this user or delete the user entirely. If realm-level admin access is needed, use a dedicated admin realm with strong credentials and MFA.

### 18. CORS wide open on all clients

- **Location:** Clients > webapp > Settings > Web Origins / Clients > spa-app > Settings > Web Origins
- **Finding:** `Web Origins` is set to `*` on both `webapp` and `spa-app`.
- **Risk:** Any website can make authenticated cross-origin requests to Keycloak on behalf of these clients. An attacker's site can silently obtain tokens or make API calls using the user's session (Cross-Origin token theft).
- **Fix:** Set `Web Origins` to specific, trusted origins only (e.g., `https://myapp.example.com`). Alternatively, use `+` to automatically derive allowed origins from the configured redirect URIs (but only if the redirect URIs are also restricted).

### 19. Offline Session Max Lifespan 1 year

- **Location:** Realm Settings > Sessions > Offline Session Max Lifespan
- **Finding:** Offline Session Max Lifespan is set to 365 days (1 year).
- **Risk:** Offline tokens (granted via the `offline_access` scope) remain valid for an entire year. Since the `webapp` client has `offline_access` as a default scope, every login automatically generates a token that grants access for up to a year. A single stolen offline token gives an attacker long-term persistent access.
- **Fix:** Reduce to a reasonable value (e.g., 30 days). Remove `offline_access` from default scopes so it is only granted when explicitly requested. Consider whether offline access is needed at all.

### 20. No MFA/OTP configured

- **Location:** Authentication > Required Actions / Authentication > Flows
- **Finding:** No second factor (OTP/WebAuthn) is configured or required. Not even for users with administrative roles (`realmadmin`). The `Configure OTP` required action exists but is not set as a default action for new users.
- **Risk:** All accounts are protected by passwords only. If a password is compromised (phishing, credential stuffing, weak password), there is no additional barrier. This is especially critical for the `realmadmin` user who has full realm-admin privileges.
- **Fix:** Enable OTP as a required action at minimum for admin users. Consider configuring Conditional OTP in the browser authentication flow (e.g., require OTP for users with admin roles). For highest security, use WebAuthn/passkeys.
