# Demo: Keycloak Security Review

## DE

**Ziel der Demo:** Ein paar Dinge bzgl. Security zeigen

**ABER:** Wir können heute nicht alles zeigen. Spezifische Einstellungen haben spezifische Anforderungen an die Einstellungen bzgl. Security.

**Umgebung:** LAB 2.2

**Vor Prod immer:** https://www.keycloak.org/docs/latest/server_admin/index.html#mitigating_security_threats

### Realm Startseite

1. **Provider Info** (Datenbankversion Postgres)
   - Beim `connectionsJPA`-Eintrag lässt sich die Postgres-Version checken.
   - Am 8.5.2024 aktuell: 16.2, 15.6, 14.11, 13.14, 12.18
   - Aktuelle & unterstützte Versionen: https://www.postgresql.org/support/versioning/
   - *"We recommend that users always run the current minor release associated with their major version."*
   - CVEs: https://www.postgresql.org/support/security/

### Realm Settings

2. **General**
   - User Managed Access erwünscht?
3. **Login**
   - Remember Me — *"Show checkbox on login page to allow user to remain logged in between browser restarts until session expires."*
     - Einschalten, wenn das Verhalten erwünscht ist; kann auch ein Hidden-Feld im Login-Form sein
   - E-Mail as Username — wie erwünscht? Abhängigkeiten erklären; weiterhin 2 Felder in der DB
   - Verify Email erwünscht?
   - Edit Username — sollte in der Regel ausgeschaltet sein, weil es oft hiervon Abhängigkeiten gibt
4. **Keys**
   - Keys sollten nicht zu lange im System bleiben und regelmäßig rotiert werden
   - https://www.keycloak.org/docs/latest/server_admin/#rotating-keys
   - *"Consider creating new keys every three to six months and deleting old keys one to two months after you create the new keys."*
5. **Events**
   - User/Admin Events Settings
   - Prüfen, ob man Events speichern will
   - Wenn man speichert, prüfen, wie lange sie aufgehoben werden sollen, damit die Platte nicht voll läuft
6. **Security Defenses**
   - Headers: mit den Defaults abgleichen
7. **Brute Force Detection**
   - Im Tab `Brute Force Detection` `Enabled` auf `On` setzen → dann kann man die Parameter sehen
   - Max Failures im Bereich 5–10
   - *"Keycloak has brute force detection capabilities and can temporarily disable a user account if the number of login failures exceeds a specified threshold."*
   - https://www.keycloak.org/docs/latest/server_admin/#password-guess-brute-force-attacks
8. **Sessions**
   - Session Idle/Max: 30 Min/10 Std sind Standard, für Remember Me entsprechend höher
9. **Tokens**
   - Signature: RS256 default; in Finance PS256, aber viele andere Systeme können das nicht, daher RS wegen Kompatibilität
   - General: Device Code Lifespan 10m, Polling Interval 5
   - Refresh Token: *"When Enabled, Keycloak revokes refresh tokens and issues another token that the client must use. This action applies to OIDC clients performing the refresh token flow."* — `Enabled` ist empfohlen; Reuse niedrig halten bei 2–3
   - Access Tokens: Lifespan 1m (nicht höher als 3m), Lifespan Implicit Flow: 15m, Login Timeout 1m
   - Action Tokens: User-Initiated 5m (30m auch okay), Admin-Initiated 12h (30 Tage auch okay)

### Authentication

10. **Policies**
    - Passwort-Policy auf Sinn prüfen (z.B. Länge 12, 1 Großbuchstabe, 1 Kleinbuchstabe, 1 Zahl, 1 Sonderzeichen)
    - OTP Reuse Token ausschalten

### Manage

11. **Users**
    - Sind alle User in der Liste bekannt? Gibt es andere User, die wir nicht kennen?
    - Mal einen User anschauen inkl. Rollen & Gruppen
    - Bei Email = Username sieht man hier keinen Usernamen mehr; in der DB gibt es das noch, ist aber synchron zur E-Mail
12. **Clients**
    - Kennen wir alle Clients hier? `account`, `account-console`, `admin-cli`, `broker`, `master-realm`, `security-admin-console` sind standardmäßig dabei
    - Clients anschauen, die genutzt werden
    - **Settings:**
      - Schauen, ob Client Authentication richtig gesetzt ist — *"This defines the type of the OIDC client. When it's ON, the OIDC type is set to confidential access type. When it's OFF, it is set to public access type"*
      - Die Flows ausschalten, die man nicht braucht; insbesondere Implicit Flow weg, wenn nicht gebraucht
      - **Standard Flow:** OAuth Authorization Code Flow — kompletter Flow mit Auth-Code gegen Access-Token-Tausch
      - **Direct Access Grants:** OAuth Resource Owner Password Credentials Grant — direkter Tausch von Username/Password gegen Token; unsicher, wenn man dafür Credentials einer Third Party geben muss
      - **Implicit Flow:** OAuth Implicit Flow — man bekommt direkt den Token und nicht nur einen Auth-Code. Problem: Das Frontend kann den Token offen sehen
      - **Service Account Roles:** Client Credentials Flow — Client kann mit seinem App-Secret direkt ohne User-Interaktion ein Token bekommen (im Namen des Clients und nicht im Namen eines Users)
      - **OAuth 2.0 Device Authorization Grant:** für Geräte ohne Browser oder mit limitierten Eingabemöglichkeiten
      - Prüfen, ob die implementierten Clients PKCE nutzen (das kann man nicht in Keycloak sehen, sondern in der tatsächlichen Implementierung der Client-Apps)
      - Redirect-URLs prüfen, keine reinen `*`
    - **Advanced:**
      - `Proof Key for Code Exchange Code Challenge Method` darf nicht leer sein, wenn PKCE genutzt wird, da es sonst gar nicht erzwungen wird

## EN

**Goal of the demo:** Show a few things related to security

**BUT:** We cannot show everything today. Specific settings have specific requirements regarding security configuration.

**Environment:** LAB 2.2

**Before production, always:** https://www.keycloak.org/docs/latest/server_admin/index.html#mitigating_security_threats

### Realm landing page

1. **Provider Info** (database version Postgres)
   - The Postgres version can be checked via the `connectionsJPA` entry.
   - As of 2024-05-08, current: 16.2, 15.6, 14.11, 13.14, 12.18
   - Current & supported versions: https://www.postgresql.org/support/versioning/
   - *"We recommend that users always run the current minor release associated with their major version."*
   - CVEs: https://www.postgresql.org/support/security/

### Realm Settings

2. **General**
   - Is User Managed Access desired?
3. **Login**
   - Remember Me — *"Show checkbox on login page to allow user to remain logged in between browser restarts until session expires."*
     - Enable it if the behavior is desired; it can also be a hidden field in the login form
   - Email as Username — as desired? Explain the dependencies; there are still 2 fields in the database
   - Is Verify Email desired?
   - Edit Username — should generally be disabled, because there are often dependencies on it
4. **Keys**
   - Keys should not remain in the system for too long and should be rotated regularly
   - https://www.keycloak.org/docs/latest/server_admin/#rotating-keys
   - *"Consider creating new keys every three to six months and deleting old keys one to two months after you create the new keys."*
5. **Events**
   - User/Admin event settings
   - Check whether you want to save events
   - If you save them, check how long they should be retained so the disk doesn't fill up
6. **Security Defenses**
   - Headers: compare against the defaults
7. **Brute Force Detection**
   - In the `Brute Force Detection` tab, set `Enabled` to `On` → then the parameters become visible
   - Max Failures in the range of 5–10
   - *"Keycloak has brute force detection capabilities and can temporarily disable a user account if the number of login failures exceeds a specified threshold."*
   - https://www.keycloak.org/docs/latest/server_admin/#password-guess-brute-force-attacks
8. **Sessions**
   - Session Idle/Max: 30 min/10 h are the defaults, correspondingly higher for Remember Me
9. **Tokens**
   - Signature: RS256 is the default; in finance, PS256, but many other systems don't support it, hence RS for compatibility
   - General: Device Code Lifespan 10m, Polling Interval 5
   - Refresh Token: *"When Enabled, Keycloak revokes refresh tokens and issues another token that the client must use. This action applies to OIDC clients performing the refresh token flow."* — `Enabled` is recommended; keep Reuse low at 2–3
   - Access Tokens: Lifespan 1m (no higher than 3m), Lifespan Implicit Flow: 15m, Login Timeout 1m
   - Action Tokens: User-Initiated 5m (30m is also okay), Admin-Initiated 12h (30 days is also okay)

### Authentication

10. **Policies**
    - Check that the password policy makes sense (e.g. length 12, 1 uppercase, 1 lowercase, 1 digit, 1 special character)
    - Disable OTP Reuse Token

### Manage

11. **Users**
    - Are all users in the list known to us? Are there other users we don't recognize?
    - Take a look at one user including roles & groups
    - With Email = Username, you no longer see a username here; it still exists in the DB, but is kept in sync with the email
12. **Clients**
    - Do we know all the clients here? `account`, `account-console`, `admin-cli`, `broker`, `master-realm`, `security-admin-console` are included by default
    - Take a look at the clients that are actually used
    - **Settings:**
      - Check that Client Authentication is set correctly — *"This defines the type of the OIDC client. When it's ON, the OIDC type is set to confidential access type. When it's OFF, it is set to public access type"*
      - Turn off the flows you don't need; in particular, remove the Implicit Flow if not needed
      - **Standard Flow:** OAuth Authorization Code Flow — complete flow exchanging an auth code for an access token
      - **Direct Access Grants:** OAuth Resource Owner Password Credentials Grant — direct exchange of username/password for a token; insecure if you have to hand over third-party credentials for it
      - **Implicit Flow:** OAuth Implicit Flow — you get the token directly instead of just an auth code. Problem: the frontend can see the token in the open
      - **Service Account Roles:** Client Credentials Flow — a client can use its app secret to obtain a token directly without user interaction (on behalf of the client, not on behalf of a user)
      - **OAuth 2.0 Device Authorization Grant:** for devices without a browser or with limited input capabilities
      - Check whether the implemented clients use PKCE (this cannot be seen in Keycloak, but only in the actual implementation of the client apps)
      - Check the redirect URLs, no plain `*` wildcards
    - **Advanced:**
      - `Proof Key for Code Exchange Code Challenge Method` must not be empty if PKCE is used, because otherwise it is not enforced at all
