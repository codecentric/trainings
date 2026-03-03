# Demo: Identity Federation via OIDC Identity Brokering

## DE

### Szenario

Zwei Unternehmen arbeiten zusammen. **meine-firma** betreibt eine Keycloak-Instanz und möchte ausgewählten Mitarbeitern der **externe-firma** Zugriff auf interne Ressourcen geben - ohne deren Benutzerdaten selbst zu verwalten.

Die Lösung: **OIDC Identity Brokering**. Keycloak in `meine-firma` vertraut dem Keycloak von `externe-firma` als Identity Provider. Externe Nutzer authentifizieren sich bei ihrem eigenen IdP. Ob sie Zugriff erhalten, steuert ein **Entitlement-Claim** bzw. **Essential-Claim** (`yourapp_access`) im ID Token.

**Ergebnis:**
- **User A** (hat Claim `yourapp_access=true`) → Login erfolgreich, wird per JIT-Provisioning in `meine-firma` angelegt
- **User B** (hat keinen Claim) → Login wird abgewiesen, **kein** User wird in `meine-firma` angelegt

Da wir für die Demo keine zwei separaten Keycloak-Instanzen brauchen, nutzen wir zwei Realms auf derselben Instanz.

### Umgebung starten

```bash
docker compose up
```

Keycloak Admin-Konsole: http://localhost:8080
Login: `admin` / `admin`

### Was wurde konfiguriert?

Die gesamte Konfiguration wird beim Start automatisch über Realm-Import-Dateien geladen. Im Folgenden wird Schritt für Schritt erklärt, was konfiguriert wurde und warum.

---

#### 1) Zwei Realms als separate Identity Provider

| Realm | Rolle |
|---|---|
| `externe-firma` | Externer Identity Provider - hier liegen die Benutzer und Passwörter |
| `meine-firma` | Service Provider - hier liegt die Anwendung (Account Console), die geschützt werden soll |

**Warum zwei Realms?** Jeder Realm ist ein eigenständiger Identity Provider mit eigenen Endpoints (`/realms/{name}/protocol/openid-connect/...`). So simulieren wir zwei getrennte Organisationen auf einer einzigen Keycloak-Instanz.

---

#### 2) Benutzer in `externe-firma`

| Username | Passwort | Attribut `yourapp_access` | Erwartetes Ergebnis |
|---|---|---|---|
| `user-a` | `test` | `true` | Zugriff erlaubt |
| `user-b` | `test` | *(nicht gesetzt)* | Zugriff verweigert |

**Warum ein User-Attribut?** Wir steuern das Entitlement über ein einfaches User-Attribut. In der Praxis könnte das auch eine Rolle, Gruppenmitgliedschaft oder ein Wert aus einem externen System sein. Entscheidend ist, dass der Wert als Claim im ID Token landet.

> **Hinweis:** Das Attribut `yourapp_access` wird über den Realm-Import in der Datenbank gespeichert, ist aber in der Admin Console unter Users → user-a → Attributes **nicht sichtbar**. Der Grund: Keycloak 26+ blendet mit dem User Profile Feature standardmäßig unbekannte ("unmanaged") Attribute in der UI aus. Der Protocol Mapper (Schritt 4) liest das Attribut trotzdem korrekt aus der Datenbank und schreibt es in den Token. Um das Attribut auch in der Admin Console sichtbar zu machen, kann unter Realm Settings → User Profile die "Unmanaged Attributes" Policy auf "Enabled" gesetzt werden.

Konfiguration: Admin Console → Realm `externe-firma` → Users

---

#### 3) OIDC-Client `meine-firma-broker` in `externe-firma`

| Einstellung | Wert | Erklärung |
|---|---|---|
| Client ID | `meine-firma-broker` | Identifiziert den Broker-Client |
| Client Type | OpenID Connect (confidential) | Standard-Flow mit Client Secret |
| Client Secret | `broker-secret` | Wird vom IdP in `meine-firma` benötigt |
| Valid Redirect URIs | `http://localhost:8080/realms/meine-firma/*` | Keycloak baut die Redirect-URI aus Realm-Name + Broker-Alias zusammen |

**Warum dieser Client?** Wenn `meine-firma` einen Benutzer zur Authentifizierung an `externe-firma` weiterleitet, agiert `meine-firma` als OIDC-Client. Dafür braucht `externe-firma` einen registrierten Client mit passender Redirect-URI.

Konfiguration: Admin Console → Realm `externe-firma` → Clients → `meine-firma-broker`

---

#### 4) Protocol Mapper: User-Attribut als Claim ins ID Token

| Einstellung | Wert |
|---|---|
| Mapper Type | User Attribute |
| User Attribute | `yourapp_access` |
| Token Claim Name | `yourapp_access` |
| Claim JSON Type | String |
| Add to ID token | ON |
| Add to access token | ON |
| Add to userinfo | ON |

**Warum ein Mapper?** Keycloak gibt User-Attribute nicht automatisch als Claims im Token aus. Der Mapper sorgt dafür, dass `yourapp_access` im ID Token erscheint - aber **nur wenn das Attribut beim User gesetzt ist**. User B hat kein solches Attribut, daher fehlt der Claim in seinem Token.

**Erwartete Tokens:**
- User A: `{ ..., "yourapp_access": "true", ... }`
- User B: `{ ... }` (kein `yourapp_access` Claim)

Konfiguration: Admin Console → Realm `externe-firma` → Clients → `meine-firma-broker` → Client scopes → `meine-firma-broker-dedicated` → Mappers

---

#### 5) OIDC Identity Provider in `meine-firma`

| Einstellung | Wert | Erklärung |
|---|---|---|
| Alias | `externe-firma` | Muss zur Redirect-URI aus Schritt 3 passen |
| Display Name | `Login über externe-firma` | Wird auf der Login-Seite angezeigt |
| Provider ID | `oidc` | OpenID Connect v1.0 |
| Authorization URL | `http://localhost:8080/realms/externe-firma/protocol/openid-connect/auth` | Browser-Redirect zum externen IdP |
| Token URL | `http://localhost:8080/realms/externe-firma/protocol/openid-connect/token` | Backchannel: Token-Austausch |
| JWKS URL | `http://localhost:8080/realms/externe-firma/protocol/openid-connect/certs` | Zum Validieren der Token-Signatur |
| Client ID | `meine-firma-broker` | Der Client aus Schritt 3 |
| Client Secret | `broker-secret` | Das Secret aus Schritt 3 |
| Validate Signatures | ON | Stellt sicher, dass Tokens nicht manipuliert wurden |
| Trust Email | ON | E-Mail aus dem externen IdP wird als verifiziert übernommen |
| Sync Mode | IMPORT | JIT-Provisioning: User wird beim ersten Login in `meine-firma` angelegt |

**Warum ein Identity Provider?** Dieser konfiguriert `meine-firma` als OIDC-Client gegenüber `externe-firma`. Beim Login erscheint ein Button "Login über externe-firma". Ein Klick leitet den Browser zur Login-Seite von `externe-firma` weiter.

Konfiguration: Admin Console → Realm `meine-firma` → Identity Providers → `externe-firma`

---

#### 6) Essential Claim: Zugriff nur mit Entitlement

| Einstellung | Wert | Erklärung |
|---|---|---|
| Verify essential claim | ON | Aktiviert die Claim-Prüfung |
| Essential claim | `yourapp_access` | Name des Claims im ID Token |
| Essential claim value | `true` | Erwarteter Wert (Regex-Match) |

**Warum Essential Claim?** Dies ist der Kern der Zugriffskontrolle. Keycloak prüft nach der Authentifizierung beim externen IdP, ob das ID Token den Claim `yourapp_access` mit dem Wert `true` enthält.

- **Claim vorhanden und Wert passt** → Authentifizierung wird fortgesetzt, User wird per JIT-Provisioning angelegt
- **Claim vorhanden aber Wert passt nicht** → Authentifizierung wird abgebrochen
- **Claim fehlt komplett** → Authentifizierung wird abgebrochen

Entscheidend: Die Prüfung findet **vor** dem Anlegen des Users in `meine-firma` statt. User B wird also nie in `meine-firma` angelegt.

Konfiguration: Admin Console → Realm `meine-firma` → Identity Providers → `externe-firma` → Einstellungen (im Abschnitt "Advanced")

---

### Demo durchführen

#### Test 1: User A - Zugriff erlaubt

1. Öffne die Account Console von `meine-firma`: http://localhost:8080/realms/meine-firma/account/
2. Klicke auf den Button **"Login über externe-firma"**
3. Du wirst zur Login-Seite von `externe-firma` weitergeleitet (erkennbar an `/realms/externe-firma/` in der URL)
4. Melde dich an mit: `user-a` / `test`
5. **Ergebnis:** Du landest in der Account Console von `meine-firma`
6. In der Admin Console unter `meine-firma` → Users ist `user-a` jetzt als gebrokerter User sichtbar (JIT-Provisioning)

#### Test 2: User B - Zugriff verweigert

1. Logge dich zuerst aus (Account Console → Sign out, oder schließe das Inkognito-Fenster)
2. Öffne erneut: http://localhost:8080/realms/meine-firma/account/
3. Klicke auf **"Login über externe-firma"**
4. Melde dich an mit: `user-b` / `test`
5. **Ergebnis:** Fehlermeldung - die Authentifizierung wird abgebrochen, weil der Claim `yourapp_access` fehlt
6. In der Admin Console unter `meine-firma` → Users ist `user-b` **nicht** vorhanden

### Optional: Direkt-Redirect zum IdP (ohne Button)

Wenn der Login-Button auf der `meine-firma`-Seite übersprungen werden soll, kann der Parameter `kc_idp_hint` verwendet werden:

```
http://localhost:8080/realms/meine-firma/account/?kc_idp_hint=externe-firma
```

Alternativ kann in der IdP-Konfiguration "Hide on login page" aktiviert werden, um den Button auszublenden.

### Aufräumen

```bash
docker compose down -v
```

---

## EN

### Scenario

Two companies are collaborating. **meine-firma** operates a Keycloak instance and wants to grant selected employees of **externe-firma** access to internal resources - without managing their user data directly.

The solution: **OIDC Identity Brokering**. Keycloak in `meine-firma` trusts the Keycloak of `externe-firma` as an Identity Provider. External users authenticate at their own IdP. Access is controlled by an **entitlement claim** (`yourapp_access`) in the ID token.

**Result:**
- **User A** (has claim `yourapp_access=true`) → Login succeeds, user is created in `meine-firma` via JIT provisioning
- **User B** (has no claim) → Login is denied, **no** user is created in `meine-firma`

Since we don't need two separate Keycloak instances for this demo, we use two realms on the same instance.

### Start the Environment

```bash
docker compose up
```

Keycloak Admin Console: http://localhost:8080
Login: `admin` / `admin`

### What Was Configured?

The entire configuration is automatically loaded on startup via realm import files. Below is a step-by-step explanation of what was configured and why.

---

#### 1) Two Realms as Separate Identity Providers

| Realm | Role |
|---|---|
| `externe-firma` | External Identity Provider - users and passwords are stored here |
| `meine-firma` | Service Provider - the application (Account Console) to be protected is here |

**Why two realms?** Each realm is an independent Identity Provider with its own endpoints (`/realms/{name}/protocol/openid-connect/...`). This simulates two separate organizations on a single Keycloak instance.

---

#### 2) Users in `externe-firma`

| Username | Password | Attribute `yourapp_access` | Expected Result |
|---|---|---|---|
| `user-a` | `test` | `true` | Access granted |
| `user-b` | `test` | *(not set)* | Access denied |

**Why a user attribute?** We control the entitlement via a simple user attribute. In practice, this could also be a role, group membership, or a value from an external system. The key point is that the value appears as a claim in the ID token.

> **Note:** The `yourapp_access` attribute is stored in the database via realm import, but is **not visible** in the Admin Console under Users → user-a → Attributes. The reason: Keycloak 26+ hides unknown ("unmanaged") attributes in the UI by default via the User Profile feature. The protocol mapper (step 4) still correctly reads the attribute from the database and writes it into the token. To make the attribute visible in the Admin Console, set the "Unmanaged Attributes" policy to "Enabled" under Realm Settings → User Profile.

Configuration: Admin Console → Realm `externe-firma` → Users

---

#### 3) OIDC Client `meine-firma-broker` in `externe-firma`

| Setting | Value | Explanation |
|---|---|---|
| Client ID | `meine-firma-broker` | Identifies the broker client |
| Client Type | OpenID Connect (confidential) | Standard flow with client secret |
| Client Secret | `broker-secret` | Required by the IdP in `meine-firma` |
| Valid Redirect URIs | `http://localhost:8080/realms/meine-firma/*` | Keycloak constructs the redirect URI from realm name + broker alias |

**Why this client?** When `meine-firma` redirects a user to `externe-firma` for authentication, `meine-firma` acts as an OIDC client. Therefore, `externe-firma` needs a registered client with the matching redirect URI.

Configuration: Admin Console → Realm `externe-firma` → Clients → `meine-firma-broker`

---

#### 4) Protocol Mapper: User Attribute as Claim in ID Token

| Setting | Value |
|---|---|
| Mapper Type | User Attribute |
| User Attribute | `yourapp_access` |
| Token Claim Name | `yourapp_access` |
| Claim JSON Type | String |
| Add to ID token | ON |
| Add to access token | ON |
| Add to userinfo | ON |

**Why a mapper?** Keycloak does not automatically include user attributes as claims in tokens. The mapper ensures that `yourapp_access` appears in the ID token - but **only when the attribute is set on the user**. User B has no such attribute, so the claim is missing from their token.

**Expected tokens:**
- User A: `{ ..., "yourapp_access": "true", ... }`
- User B: `{ ... }` (no `yourapp_access` claim)

Configuration: Admin Console → Realm `externe-firma` → Clients → `meine-firma-broker` → Client scopes → `meine-firma-broker-dedicated` → Mappers

---

#### 5) OIDC Identity Provider in `meine-firma`

| Setting | Value | Explanation |
|---|---|---|
| Alias | `externe-firma` | Must match the redirect URI from step 3 |
| Display Name | `Login über externe-firma` | Shown on the login page |
| Provider ID | `oidc` | OpenID Connect v1.0 |
| Authorization URL | `http://localhost:8080/realms/externe-firma/protocol/openid-connect/auth` | Browser redirect to external IdP |
| Token URL | `http://localhost:8080/realms/externe-firma/protocol/openid-connect/token` | Backchannel: token exchange |
| JWKS URL | `http://localhost:8080/realms/externe-firma/protocol/openid-connect/certs` | For validating token signatures |
| Client ID | `meine-firma-broker` | The client from step 3 |
| Client Secret | `broker-secret` | The secret from step 3 |
| Validate Signatures | ON | Ensures tokens have not been tampered with |
| Trust Email | ON | Email from the external IdP is accepted as verified |
| Sync Mode | IMPORT | JIT provisioning: user is created in `meine-firma` on first login |

**Why an Identity Provider?** This configures `meine-firma` as an OIDC client towards `externe-firma`. On the login page, a button "Login über externe-firma" appears. Clicking it redirects the browser to the login page of `externe-firma`.

Configuration: Admin Console → Realm `meine-firma` → Identity Providers → `externe-firma`

---

#### 6) Essential Claim: Access Only with Entitlement

| Setting | Value | Explanation |
|---|---|---|
| Verify essential claim | ON | Enables the claim check |
| Essential claim | `yourapp_access` | Name of the claim in the ID token |
| Essential claim value | `true` | Expected value (regex match) |

**Why Essential Claim?** This is the core of the access control. After authentication at the external IdP, Keycloak checks whether the ID token contains the claim `yourapp_access` with the value `true`.

- **Claim present and value matches** → Authentication continues, user is created via JIT provisioning
- **Claim present but value does not match** → Authentication is aborted
- **Claim is missing entirely** → Authentication is aborted

Crucially: The check happens **before** the user is created in `meine-firma`. User B is therefore never created in `meine-firma`.

Configuration: Admin Console → Realm `meine-firma` → Identity Providers → `externe-firma` → Settings (in the "Advanced" section)

---

### Run the Demo

#### Test 1: User A - Access Granted

1. Open the Account Console of `meine-firma`: http://localhost:8080/realms/meine-firma/account/
2. Click the **"Login über externe-firma"** button
3. You are redirected to the login page of `externe-firma` (recognizable by `/realms/externe-firma/` in the URL)
4. Log in with: `user-a` / `test`
5. **Result:** You land on the Account Console of `meine-firma`
6. In the Admin Console under `meine-firma` → Users, `user-a` is now visible as a brokered user (JIT provisioning)

#### Test 2: User B - Access Denied

1. First log out (Account Console → Sign out, or close the incognito window)
2. Open again: http://localhost:8080/realms/meine-firma/account/
3. Click **"Login über externe-firma"**
4. Log in with: `user-b` / `test`
5. **Result:** Error message - authentication is aborted because the claim `yourapp_access` is missing
6. In the Admin Console under `meine-firma` → Users, `user-b` is **not** present

### Optional: Direct Redirect to IdP (Without Button)

To skip the login button on the `meine-firma` page, use the `kc_idp_hint` parameter:

```
http://localhost:8080/realms/meine-firma/account/?kc_idp_hint=externe-firma
```

Alternatively, enable "Hide on login page" in the IdP configuration to hide the button.

### Cleanup

```bash
docker compose down -v
```
