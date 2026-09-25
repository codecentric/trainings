# Demo: Keycloak Admin Console

## DE

**Ziel der Demo:** Grobe Übersicht über die Admin Console

**Umgebung:** LAB 2.2

**Neuen Realm anlegen**

### Configure → Realm Settings

1. **General**
   - Realm Name → ändert auch die URL !!!
   - User-managed Access: aktiviert für die Account Konsole den Tab `Resources`
   - Endpoints: mal den OpenID-Endpoint mit seinen Inhalten zeigen
     - OpenID Connect `.well-known` zeigen & durchgehen
   - Oben rechts: Import/Export
2. **Login**
   - Email as Username: wird doppelt in der DB gespeichert; mit Bedacht nachträglich ändern!
   - Edit Username: nur einschalten, wenn die eigenen Clients auch damit umgehen können
   - Email
   - Themes (später in Labs)
3. **Keys**
   - Zur Rotation erkläre ich nochmal was im Security Review
4. **Events**
   - Es können eigene Event Listener implementiert und hinzugefügt werden
   - Zeigen, dass man User/Admin Events erst noch einschalten muss
   - Admin Events mal einschalten und dann im Events-Bereich (Hauptmenü) zeigen, dass dort im Admin-Events-Tab etwas sichtbar ist
   - Auf Speicherplatzproblem hinweisen
5. **Localization**
6. **Security Defenses**
7. **Brute Force Detection**
8. **Sessions**
   - **SSO Session Settings (Single Sign-On):**
     - `SSO Session Idle` — Zeit, wie lange eine SSO-Session inaktiv sein darf, bevor sie automatisch abläuft. → z.B. 30 Minuten = Benutzer wird nach 30 Minuten Inaktivität abgemeldet.
     - `SSO Session Max` — maximale Lebensdauer der SSO-Session, egal ob der Benutzer aktiv ist oder nicht. → z.B. 10 Stunden = spätestens nach 10 Stunden muss sich der Benutzer neu anmelden.
     - `SSO Session Idle Remember Me` — wie lange eine "Remember-Me"-Session inaktiv sein darf, bevor sie abläuft. → wird nur verwendet, wenn "Remember Me" beim Login aktiviert ist.
     - `SSO Session Max Remember Me` — maximale Lebensdauer einer "Remember-Me"-Session.
   - **Client Session Settings** — hier stellst du die Lebensdauer von Client-Sitzungen (nicht SSO) ein:
     - `Client Session Idle` = Inaktivitätszeit für eine einzelne Client-Sitzung.
     - `Client Session Max` = maximale Lebensdauer einer einzelnen Client-Sitzung.
   - **Offline Session Settings** — für Offline-Token (z.B. bei mobilen Apps):
     - `Offline Session Idle` — Zeit, wie lange eine Offline-Session inaktiv sein darf (Standard oft 30 Tage).
     - `Offline Session Max Limited` — Schalter, um eine maximale Lebensdauer für Offline-Sessions zu erzwingen.
9. **Tokens**
   - **Access Tokens:**
     - `Access Token Lifespan` — Gültigkeitsdauer eines normalen Access Tokens. → Empfehlung: kürzer als der "SSO Session Idle Timeout".
     - `Access Token Lifespan For Implicit Flow` — Access-Token-Gültigkeit bei Verwendung des Implicit Flows.
     - `Client Login Timeout` — Zeit, die ein Client hat, um sich beim Server anzumelden.
   - **Hinweise zu Sessions & Tokens:**
     - Zwei "Schichten" bei Keycloak:
       - **Session (SSO Session)** = die serverseitige Sitzung zwischen Benutzer und Keycloak (Keycloak merkt sich: dieser Benutzer ist angemeldet).
       - **Token (Access / Refresh Tokens)** = die clientseitigen kryptografischen Nachweise, mit denen Apps beim Server beweisen: "Ich bin dieser Benutzer" (liegen beim Client / Browser / App).
     - **Sicherheit:** kurze Tokens → wenig Schaden bei Diebstahl.
     - **Usability:** lange Session → Benutzer bleibt eingeloggt, muss nicht ständig das Passwort eingeben.
     - Access Tokens können (rein technisch) länger gültig sein als eine Session. Das ist aber nicht empfohlen, weil es einen Zeitraum gibt, in dem der Benutzer schon abgemeldet ist, aber das Token noch funktioniert.
10. **Client Policies**
    - Spezifika zu OAuth oder andere Sicherheitsprofile können erzwungen werden
    - Sehr spezifisch für den Anwendungsfall
    - Einfachstes Beispiel: hier kann festgelegt werden, wie beispielsweise PKCE erzwungen wird (`oauth-2-1-for-public-client` → PKCE Enforcer)
11. **User Profile**
    - Festlegen, welche Attribute ein Userprofil hat
    - User Registration
    - Default Rollen und Gruppen für einen Benutzer festlegen

### Authentication

12. **Flows**
    - Mal den Browser Flow und den Registration Flow zeigen
13. **Identity Providers**
14. **User Federation**

### Manage → Clients

15. **Clients durchgehen** (insbesondere `admin-cli`, `account-console`), auch die Account Console mal aufrufen
16. **Mal einen Client anlegen (`democlient`) und Optionen erklären:**
    - **Authorization:** Fine Grained Permissions steuern innerhalb eines Clients die Berechtigungen noch genauer und nicht so global
    - **Keys:** eigene Key Pairs für diesen Client festlegen
    - **Credentials**
    - **Rollen:** eigene, clientspezifische, die nicht von anderen Clients genutzt werden können
    - **Client Scopes** → Demo kommt noch
    - **Service Account Roles:** Service Account = M2M-Zugriff durch eine Maschine ohne User. Welche Rollen hat ein Service Account, der auf den Client zugreift?
    - **Sessions:** aktive Sessions dieses Clients
    - **Permissions:** Fine Grained Permissions, noch recht neu, in diesem Kurs ausgeklammert
    - **Advanced:** technische Einstellungen, können üblicherweise erstmal so bleiben. Wir kommen dafür im Security Review darauf zurück.
17. **Client Scopes** → Demo kommt noch

### Manage → Realm Roles

18. Das gleiche wie Client Roles, aber global für alle Clients im Realm

### Manage → Users

19. **Neuen Benutzer anlegen**
    - Required Actions erklären
    - Required Actions mit `Update Password` mal zeigen durch Login in die Account Console
    - Credentials-Tab zeigen
    - Für einen Account in der Account Console mal ein OTP festlegen und zeigen, dass das dann dort erscheint
    - **Role Mapping:** Rollen zuweisen …
    - **Groups**
    - **Consent:** für den Client `account-console` mal im Settings-Tab `Consent Required` einschalten, sich dann einloggen und zustimmen → dann erscheint hier die Account Console in der Liste
    - **Identity Provider Links:** wenn der User aus einem Identity Provider kommt …
    - **Sessions**

### Manage → Groups, Sessions, Events

20. **Groups**
21. **Sessions**
22. **Events**

## EN

**Goal of the demo:** Rough overview of the Admin Console

**Environment:** LAB 2.2

**Create a new realm**

### Configure → Realm Settings

1. **General**
   - Realm name → this also changes the URL !!!
   - User-managed Access: enables the `Resources` tab in the account console
   - Endpoints: show the OpenID endpoint and its contents
     - Show the OpenID Connect `.well-known` endpoint and walk through it
   - Top right: Import/Export
2. **Login**
   - Email as Username: stored twice in the database; change later only with care!
   - Edit Username: only enable if your own clients can handle it
   - Email
   - Themes (later in the labs)
3. **Keys**
   - I'll explain more about rotation in the Security Review demo
4. **Events**
   - Custom event listeners can be implemented and added
   - Show that User/Admin events first have to be enabled
   - Enable Admin events, then show in the Events area (main menu) that something is now visible in the Admin Events tab
   - Point out the storage space concern
5. **Localization**
6. **Security Defenses**
7. **Brute Force Detection**
8. **Sessions**
   - **SSO Session Settings (Single Sign-On):**
     - `SSO Session Idle` — how long an SSO session may be inactive before it automatically expires. → e.g. 30 minutes = the user is logged out after 30 minutes of inactivity.
     - `SSO Session Max` — maximum lifetime of the SSO session, regardless of whether the user is active. → e.g. 10 hours = at the latest after 10 hours, the user must log in again.
     - `SSO Session Idle Remember Me` — how long a "Remember Me" session may be inactive before it expires. → only used if "Remember Me" was activated at login.
     - `SSO Session Max Remember Me` — maximum lifetime of a "Remember Me" session.
   - **Client Session Settings** — here you configure the lifetime of client sessions (not SSO):
     - `Client Session Idle` = inactivity timeout for a single client session.
     - `Client Session Max` = maximum lifetime of a single client session.
   - **Offline Session Settings** — for offline tokens (e.g. mobile apps):
     - `Offline Session Idle` — how long an offline session may be inactive (default is often 30 days).
     - `Offline Session Max Limited` — switch to enforce a maximum lifetime for offline sessions.
9. **Tokens**
   - **Access Tokens:**
     - `Access Token Lifespan` — validity period of a regular access token. → Recommendation: shorter than the "SSO Session Idle Timeout".
     - `Access Token Lifespan For Implicit Flow` — access token validity when the Implicit Flow is used.
     - `Client Login Timeout` — time a client has to complete its login with the server.
   - **Notes on sessions & tokens:**
     - Two "layers" in Keycloak:
       - **Session (SSO Session)** = the server-side session between user and Keycloak (Keycloak remembers: this user is logged in).
       - **Token (Access / Refresh Tokens)** = the client-side cryptographic evidence with which apps prove to the server: "I am this user" (held by the client / browser / app).
     - **Security:** short tokens → little damage if stolen.
     - **Usability:** long session → the user stays logged in and doesn't have to enter the password constantly.
     - Access tokens can (technically) be valid longer than a session. This is not recommended, however, because it creates a window where the user is already logged out but the token still works.
10. **Client Policies**
    - OAuth specifics or other security profiles can be enforced
    - Very specific to the use case
    - Simplest example: this is where you can define how, for example, PKCE is enforced (`oauth-2-1-for-public-client` → PKCE Enforcer)
11. **User Profile**
    - Define which attributes a user profile has
    - User Registration
    - Define default roles and groups for a user

### Authentication

12. **Flows**
    - Show the Browser Flow and the Registration Flow
13. **Identity Providers**
14. **User Federation**

### Manage → Clients

15. **Walk through the clients** (especially `admin-cli`, `account-console`), also open the account console once
16. **Create a client (`democlient`) and explain the options:**
    - **Authorization:** Fine-grained permissions control permissions within a client more granularly, not so globally
    - **Keys:** define dedicated key pairs for this client
    - **Credentials**
    - **Roles:** client-specific roles that cannot be used by other clients
    - **Client Scopes** → demo coming later
    - **Service Account Roles:** Service Account = M2M access by a machine without a user. Which roles does a service account accessing the client have?
    - **Sessions:** active sessions of this client
    - **Permissions:** fine-grained permissions, still fairly new, excluded from this course
    - **Advanced:** technical settings, can usually stay as they are for now. We'll come back to this in the Security Review.
17. **Client Scopes** → demo coming later

### Manage → Realm Roles

18. Same as client roles, but global for all clients in the realm

### Manage → Users

19. **Create a new user**
    - Explain Required Actions
    - Demonstrate the `Update Password` Required Action by logging into the account console
    - Show the Credentials tab
    - Set up OTP for an account in the account console and show that it then appears there
    - **Role Mapping:** assign roles …
    - **Groups**
    - **Consent:** enable `Consent Required` in the Settings tab for the `account-console` client, then log in and consent → the account console then appears in the list here
    - **Identity Provider Links:** when the user comes from an identity provider …
    - **Sessions**

### Manage → Groups, Sessions, Events

20. **Groups**
21. **Sessions**
22. **Events**
