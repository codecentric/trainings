# Lab Security Hardening - Solution (Trainer Reference)

# DE

## Zusammenfassung

| # | Problem | Ort | Schweregrad |
|---|---------|-----|-------------|
| 1 | SSL Required = none | Realm Settings > General | Kritisch |
| 2 | Brute Force Protection deaktiviert | Realm Settings > Security Defenses | Hoch |
| 3 | Schwaches Password Hashing (1 Iteration) | Authentication > Policies > Password Policy | Kritisch |
| 4 | Login Events deaktiviert | Realm Settings > Events | Mittel |
| 5 | Admin Events deaktiviert | Realm Settings > Events | Mittel |
| 6 | Access Token Lifetime 60 min | Realm Settings > Tokens | Hoch |
| 7 | SSO Session Idle 24 Stunden | Realm Settings > Sessions | Mittel |
| 8 | SSO Session Max 30 Tage | Realm Settings > Sessions | Hoch |
| 9 | Refresh Token Revocation deaktiviert | Realm Settings > Tokens | Mittel |
| 10 | Selbstregistrierung ohne E-Mail-Verifizierung | Realm Settings > Login / Email | Mittel |
| 11 | Alle Security Headers leer | Realm Settings > Security Defenses > Headers | Hoch |
| 12 | webapp: Multiple kritische Client-Fehlkonfigurationen | Clients > webapp | Kritisch |
| 13 | service-account-client: realm-admin Rolle + schwaches Secret | Clients > service-account-client | Kritisch |
| 14 | realmadmin: Admin-Benutzer im Application Realm | Users > realmadmin | Hoch |
| 19 | Offline Session Max Lifespan 1 Jahr | Realm Settings > Sessions | Hoch |
| 20 | Kein MFA/OTP konfiguriert | Authentication > Required Actions / Flows | Hoch |

---

## Detaillierte Befunde

### 1. SSL Required = none

- **Ort:** Realm Settings > General > Require SSL
- **Befund:** `Require SSL` ist auf `None` gesetzt. Alle Kommunikation erfolgt unverschlüsselt.
- **Risiko:** Zugangsdaten und Tokens werden im Klartext übertragen. Man-in-the-Middle-Angriffe können sensible Daten abfangen.
- **Lösung:** Auf `External requests` (mindestens) oder `All requests` für Produktion setzen.

### 2. Brute Force Protection deaktiviert

- **Ort:** Realm Settings > Security Defenses > Brute Force Detection
- **Befund:** Brute Force Detection ist deaktiviert.
- **Risiko:** Angreifer können unbegrenzt Login-Versuche durchführen, um Passwörter zu erraten.
- **Lösung:** Brute Force Detection aktivieren. `Max Login Failures` (z.B. 5), `Wait Increment` und `Max Wait` entsprechend konfigurieren.

### 3. Schwaches Password Hashing (1 Iteration)

- **Ort:** Authentication > Policies > Password Policy
- **Befund:** Die Passwort-Policy enthält nur `hashIterations(1)`. Dies reduziert PBKDF2-Hashing auf eine einzige Iteration (Keycloak-Standard: 210.000). Zusätzlich sind keine anderen Passwort-Policies konfiguriert - keine Mindestlänge, Komplexität oder Verlaufsanforderungen.
- **Risiko:** Zwei Probleme in einem: (1) Wenn die Datenbank kompromittiert wird, können Passwort-Hashes fast sofort geknackt werden. Mit 210.000 Iterationen dauert das Brute-Forcing eines einzelnen Hashes erhebliche Zeit. Mit 1 Iteration sind Millionen von Versuchen pro Sekunde möglich. (2) Benutzer können jedes Passwort setzen, einschließlich `1` oder `password`.
- **Lösung:** `hashIterations(1)` entfernen (oder auf mindestens 210.000 setzen). Policies hinzufügen: Mindestlänge (8+), Großbuchstaben, Kleinbuchstaben, Ziffern, Sonderzeichen, nicht Benutzername, Passwort-Historie.

### 4. Login Events deaktiviert

- **Ort:** Realm Settings > Events > User events settings
- **Befund:** `Save events` ist deaktiviert.
- **Risiko:** Kein Audit-Trail für Login-Versuche, fehlgeschlagene Logins oder verdächtige Aktivitäten. Sicherheitsvorfälle können nicht untersucht werden.
- **Lösung:** `Save events` aktivieren und eine angemessene Aufbewahrungsfrist festlegen (z.B. 30 Tage). Error-Events einschließen.

### 5. Admin Events deaktiviert

- **Ort:** Realm Settings > Events > Admin events settings
- **Befund:** `Save events` für Admin-Events ist deaktiviert.
- **Risiko:** Kein Audit-Trail für administrative Änderungen. Unautorisierte Konfigurationsänderungen bleiben unbemerkt.
- **Lösung:** Admin-Event-Logging aktivieren. `Include representation` für vollständiges Change-Tracking in Erwägung ziehen.

### 6. Access Token Lifetime 60 Minuten

- **Ort:** Realm Settings > Tokens > Access Token Lifespan
- **Befund:** Access Token Lifespan ist auf 60 Minuten gesetzt (Standard ist 5 Minuten).
- **Risiko:** Wenn ein Token gestohlen wird, hat der Angreifer ein 60-Minuten-Zeitfenster, um es zu nutzen. Access Tokens sind typischerweise nicht widerrufbar.
- **Lösung:** Auf 5 Minuten oder weniger setzen. Refresh Tokens für längere Sessions verwenden.

### 7. SSO Session Idle 24 Stunden

- **Ort:** Realm Settings > Sessions > SSO Session Idle
- **Befund:** SSO Session Idle Timeout ist auf 24 Stunden gesetzt (Standard ist 30 Minuten).
- **Risiko:** Unbeaufsichtigte Sessions bleiben einen ganzen Tag gültig. Wenn ein Benutzer seinen Computer verlässt, bleibt die Session aktiv.
- **Lösung:** Auf 30 Minuten oder weniger setzen, abhängig von den Sicherheitsanforderungen.

### 8. SSO Session Max 30 Tage

- **Ort:** Realm Settings > Sessions > SSO Session Max
- **Befund:** SSO Session Max Lifespan ist auf 30 Tage gesetzt (Standard ist 10 Stunden).
- **Risiko:** Selbst aktiv genutzte Sessions bleiben einen ganzen Monat gültig ohne erneute Authentifizierung. Kombiniert mit dem 24h Idle-Timeout gibt ein gestohlenes Session-Cookie einem Angreifer bis zu 30 Tage Zugriff. Das Max-Timeout ist die absolute Obergrenze - das Idle-Timeout hilft nur, wenn der Angreifer die Session nicht mehr nutzt.
- **Lösung:** Auf 8-10 Stunden für typische Business-Anwendungen setzen. Dies erzwingt tägliche Neuauthentifizierung unabhängig von der Aktivität.

### 9. Refresh Token Revocation deaktiviert

- **Ort:** Realm Settings > Tokens > Revoke Refresh Token
- **Befund:** `Revoke Refresh Token` ist deaktiviert.
- **Risiko:** Refresh Tokens können unbegrenzt wiederverwendet werden. Ein gestohlenes Refresh Token gewährt dauerhaften Zugriff.
- **Lösung:** `Revoke Refresh Token` aktivieren. `Refresh Token Max Reuse` auf 0 für einmalige Verwendung setzen (Rotation).

### 10. Selbstregistrierung ohne E-Mail-Verifizierung

- **Ort:** Realm Settings > Login (`User registration` aktiviert) / Realm Settings > Login (`Verify email` deaktiviert)
- **Befund:** Benutzer-Selbstregistrierung ist aktiviert, aber E-Mail-Verifizierung ist deaktiviert.
- **Risiko:** Jeder kann Konten mit gefälschten E-Mail-Adressen registrieren. Ermöglicht Spam-Konten, Identitätsdiebstahl und Missbrauch.
- **Lösung:** Entweder Selbstregistrierung deaktivieren oder `Verify email` aktivieren, um gültigen E-Mail-Besitz sicherzustellen.

### 11. Alle Security Headers leer

- **Ort:** Realm Settings > Security Defenses > Headers
- **Befund:** Alle Browser-Sicherheitsheader sind auf leere Strings gesetzt.
- **Risiko:** Fehlender Schutz gegen Clickjacking (X-Frame-Options), MIME-Sniffing (X-Content-Type-Options), XSS (X-XSS-Protection, CSP) und mehr.
- **Lösung:** Keycloak-Standardwerte wiederherstellen:
  - `X-Frame-Options: SAMEORIGIN`
  - `Content-Security-Policy: frame-src 'self'; frame-ancestors 'self'; object-src 'none';`
  - `X-Content-Type-Options: nosniff`
  - `X-XSS-Protection: 1; mode=block`
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
  - `Referrer-Policy: no-referrer`
  - `X-Robots-Tag: none`

### 12. webapp: Multiple kritische Client-Fehlkonfigurationen

- **Ort:** Clients > webapp > Settings / Advanced / Client Scopes
- **Befund:** Der `webapp` Client kombiniert mehrere kritische Sicherheitsprobleme:
  - Wildcard Redirect URI (`*`) - akzeptiert jede URL als Redirect-Ziel
  - PKCE nicht erzwungen (`pkce.code.challenge.method` ist leer)
  - Public Client (kein Secret erforderlich)
  - Nur Implicit Flow aktiviert, Standard Flow (Authorization Code) deaktiviert
  - Direct Access Grants (ROPC) aktiviert auf einem public client
  - `offline_access` als Default Scope konfiguriert
  - Web Origins auf `*` gesetzt (CORS weit offen)
- **Risiko:**
  - **Wildcard Redirect:** Angreifer können Authorization Codes/Tokens zu beliebigen URLs umleiten (Open Redirect / Authorization Code Interception)
  - **Kein PKCE:** Authorization Codes können bei public clients abgefangen werden - besonders kritisch ohne Client Secret
  - **Nur Implicit Flow:** Deprecated für moderne Apps (OAuth 2.1). Tokens werden im URL-Fragment offengelegt (Browser-Historie, Referrer-Header, Server-Logs)
  - **Direct Access Grants auf public client:** Jedes JavaScript kann Benutzername/Passwort direkt an Keycloak senden - keine sichere Authentifizierung mehr
  - **offline_access als Default:** Gewährt automatisch langlebige Refresh Tokens (bis zu 1 Jahr) für jede Session
  - **CORS `*`:** Jede Website kann authentifizierte Requests an Keycloak im Namen dieses Clients durchführen
- **Lösung:**
  - Spezifische Redirect URIs setzen (z.B. `https://myapp.example.com/callback`)
  - `pkce.code.challenge.method` auf `S256` setzen
  - Standard Flow (Authorization Code) aktivieren, Implicit Flow deaktivieren
  - Direct Access Grants deaktivieren
  - `offline_access` aus Default Scopes entfernen und zu optionalen Scopes verschieben
  - Web Origins auf spezifische Origins einschränken (z.B. `https://myapp.example.com`) oder `+` verwenden

### 13. service-account-client: realm-admin Rolle + schwaches Secret

- **Ort:** Clients > service-account-client > Credentials / Service Account Roles
- **Befund:** Das Client Secret ist `password`. Der Service Account hat die `realm-admin` Rolle zugewiesen.
- **Risiko:**
  - Ein trivial erratbares Client Secret bedeutet, dass jeder Tokens für diesen Client erhalten kann.
  - Mit `realm-admin` hat dieser Client vollen administrativen Zugriff auf den gesamten Realm (Benutzer erstellen/löschen, Clients ändern, Einstellungen ändern).
  - Kombiniert: Jeder, der das Secret errät, erhält vollen Realm-Admin-Zugriff.
- **Lösung:** Starkes, zufälliges Client Secret generieren. `realm-admin` Rolle entfernen. Nur minimal erforderliche Rollen nach dem Prinzip der geringsten Berechtigung zuweisen.

### 14. realmadmin: Admin-Benutzer im Application Realm

- **Ort:** Users > realmadmin > Role Mappings
- **Befund:** Ein Benutzer `realmadmin` existiert mit der `realm-admin` Client-Rolle von `realm-management`.
- **Risiko:** Ein Application-Realm-Benutzer hat vollen administrativen Zugriff. Wenn das Konto kompromittiert wird (schwaches Passwort `admin123`), kann der Angreifer die gesamte Realm-Konfiguration ändern.
- **Lösung:** Administrativer Zugriff sollte nur über den `master` Realm verwaltet werden. `realm-admin` Rolle von diesem Benutzer entfernen oder Benutzer komplett löschen. Wenn Realm-Level Admin-Zugriff benötigt wird, einen dedizierten Admin-Realm mit starken Credentials und MFA verwenden.

### 15. Offline Session Max Lifespan 1 Jahr

- **Ort:** Realm Settings > Sessions > Offline Session Max Lifespan
- **Befund:** Offline Session Max Lifespan ist auf 365 Tage (1 Jahr) gesetzt.
- **Risiko:** Offline Tokens (gewährt über den `offline_access` Scope) bleiben ein ganzes Jahr gültig. Da der `webapp` Client `offline_access` als Default Scope hat, generiert jeder Login automatisch ein Token, das bis zu einem Jahr Zugriff gewährt. Ein einzelnes gestohlenes Offline Token gibt einem Angreifer langfristigen persistenten Zugriff.
- **Lösung:** Auf einen vernünftigen Wert reduzieren (z.B. 30 Tage). `offline_access` aus Default Scopes entfernen, sodass es nur bei expliziter Anforderung gewährt wird. Überlegen, ob Offline-Zugriff überhaupt benötigt wird.

### 16. Kein MFA/OTP konfiguriert

- **Ort:** Authentication > Required Actions / Authentication > Flows
- **Befund:** Kein zweiter Faktor (OTP/WebAuthn) ist konfiguriert oder erforderlich. Nicht einmal für Benutzer mit administrativen Rollen (`realmadmin`). Die `Configure OTP` Required Action existiert, ist aber nicht als Standard-Aktion für neue Benutzer gesetzt.
- **Risiko:** Alle Konten sind nur durch Passwörter geschützt. Wenn ein Passwort kompromittiert wird (Phishing, Credential Stuffing, schwaches Passwort), gibt es keine zusätzliche Barriere. Dies ist besonders kritisch für den `realmadmin` Benutzer, der volle Realm-Admin-Rechte hat.
- **Lösung:** OTP mindestens für Admin-Benutzer als Required Action aktivieren. Conditional OTP im Browser Authentication Flow konfigurieren (z.B. OTP für Benutzer mit Admin-Rollen verlangen). Für höchste Sicherheit WebAuthn/Passkeys verwenden.

---

# EN

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
| 12 | webapp: Multiple critical client misconfigurations | Clients > webapp | Critical |
| 13 | service-account-client: realm-admin role + weak secret | Clients > service-account-client | Critical |
| 14 | realmadmin: Admin user in application realm | Users > realmadmin | High |
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

### 12. webapp: Multiple critical client misconfigurations

- **Location:** Clients > webapp > Settings / Advanced / Client Scopes
- **Finding:** The `webapp` client combines multiple critical security issues:
  - Wildcard Redirect URI (`*`) - accepts any URL as redirect target
  - PKCE not enforced (`pkce.code.challenge.method` is empty)
  - Public Client (no secret required)
  - Only Implicit Flow enabled, Standard Flow (Authorization Code) disabled
  - Direct Access Grants enabled on a public client
  - `offline_access` configured as default scope
  - Web Origins set to `*` (CORS wide open)
- **Risk:**
  - **Wildcard Redirect:** Attackers can redirect authorization codes/tokens to any URL they control (Open Redirect / Authorization Code Interception)
  - **No PKCE:** Authorization codes can be intercepted on public clients - especially critical without client secret
  - **Implicit Flow only:** Deprecated for modern apps (OAuth 2.1). Tokens exposed in URL fragment (browser history, referrer headers, server logs)
  - **Direct Access Grants on public client:** Any JavaScript can send username/password directly to Keycloak - no secure authentication
  - **offline_access as default:** Automatically grants long-lived refresh tokens (up to 1 year) for every session
  - **CORS `*`:** Any website can make authenticated requests to Keycloak on behalf of this client
- **Fix:**
  - Set specific redirect URIs (e.g., `https://myapp.example.com/callback`)
  - Set `pkce.code.challenge.method` to `S256`
  - Enable Standard Flow (Authorization Code), disable Implicit Flow
  - Disable Direct Access Grants
  - Remove `offline_access` from default scopes and move to optional scopes
  - Restrict Web Origins to specific origins (e.g., `https://myapp.example.com`) or use `+`

### 13. service-account-client: realm-admin role + weak secret

- **Location:** Clients > service-account-client > Credentials / Service Account Roles
- **Finding:** The client secret is `password`. The service account has the `realm-admin` role assigned.
- **Risk:**
  - A trivially guessable client secret means anyone can obtain tokens for this client.
  - With `realm-admin`, this client has full administrative access to the entire realm (create/delete users, modify clients, change settings).
  - Combined: anyone who guesses the secret gains full realm admin access.
- **Fix:** Generate a strong, random client secret. Remove `realm-admin` role. Assign only the minimum required roles following the principle of least privilege.

### 14. realmadmin: Admin user in application realm

- **Location:** Users > realmadmin > Role Mappings
- **Finding:** A user `realmadmin` exists with the `realm-admin` client role from `realm-management`.
- **Risk:** An application realm user has full administrative access. If the account is compromised (weak password `admin123`), the attacker can modify the entire realm configuration.
- **Fix:** Administrative access should be managed through the `master` realm only. Remove the `realm-admin` role from this user or delete the user entirely. If realm-level admin access is needed, use a dedicated admin realm with strong credentials and MFA.

### 15. Offline Session Max Lifespan 1 year

- **Location:** Realm Settings > Sessions > Offline Session Max Lifespan
- **Finding:** Offline Session Max Lifespan is set to 365 days (1 year).
- **Risk:** Offline tokens (granted via the `offline_access` scope) remain valid for an entire year. Since the `webapp` client has `offline_access` as a default scope, every login automatically generates a token that grants access for up to a year. A single stolen offline token gives an attacker long-term persistent access.
- **Fix:** Reduce to a reasonable value (e.g., 30 days). Remove `offline_access` from default scopes so it is only granted when explicitly requested. Consider whether offline access is needed at all.

### 16. No MFA/OTP configured

- **Location:** Authentication > Required Actions / Authentication > Flows
- **Finding:** No second factor (OTP/WebAuthn) is configured or required. Not even for users with administrative roles (`realmadmin`). The `Configure OTP` required action exists but is not set as a default action for new users.
- **Risk:** All accounts are protected by passwords only. If a password is compromised (phishing, credential stuffing, weak password), there is no additional barrier. This is especially critical for the `realmadmin` user who has full realm-admin privileges.
- **Fix:** Enable OTP as a required action at minimum for admin users. Consider configuring Conditional OTP in the browser authentication flow (e.g., require OTP for users with admin roles). For highest security, use WebAuthn/passkeys.
