# Lab SSO

## DE

1) Startet das Lab via `docker compose up`. Der Realm `acme` mit zwei OIDC-Clients (`outline`, `nextcloud`) und einem Testbenutzer (`testuser` / `test`) wird automatisch importiert.
2) Prüft in der Keycloak Admin Console (http://localhost:8080), ob der Realm `acme` sowie die beiden Clients und der Testbenutzer vorhanden sind.
3) Öffnet Outline unter http://localhost:8082 und klickt auf `Continue with Keycloak`. Loggt euch mit dem Testbenutzer ein. Outline ist bereits via Environmentvariablen für OIDC konfiguriert.
4) Konfiguriert nun Nextcloud (http://localhost:8081) für OIDC (Hinweis: manchmal sind die Übersetzungen nicht selbstsprechend ;) ):
   * Loggt euch als `admin` / `admin` ein.
   * Geht zu `Apps` und installiert die App `Social Login` (Suche benutzen).
   * Geht zu `Verwaltung` → `Social login` und richtet einen neuen Provider ein:
     * Benutzerdefiniertes OpenID-Connect / Custom OpenID Connect
     * Interner name: kc-masterclass (interne ID, kann nicht mehr geändert werden)
     * Titel: Keycloak Masterclass (Anzeigename)
     * Authorize URL: `http://localhost:8080/realms/acme/protocol/openid-connect/auth`
     * Token-URL: `http://keycloak:8080/realms/acme/protocol/openid-connect/token`
     * Userinfo-URL: `http://keycloak:8080/realms/acme/protocol/openid-connect/userinfo`
     * Logout-URL: `http://localhost:8080/realms/acme/protocol/openid-connect/logout`
     * Client ID: `nextcloud`
     * Client Secret: `nextcloud-secret`
     * Scope: `openid`
5) Speichern und aus der Nextcloud ausloggen.
6) Testet SSO: Öffnet Nextcloud (http://localhost:8081) in einem neuen Tab und klickt auf `Anmelnden/Login mit Keycloak Masterclass`. Da ihr bereits über Outline bei Keycloak eingeloggt seid, solltet ihr ohne erneute Passworteingabe eingeloggt werden.
7) Loggt euch in der Nextcloud aus und prüft, ob ihr noch in Outline eingeloggt seid (wir haben eine Zombie Session)


## EN

1) Start the lab via `docker compose up`. The realm `acme` with two OIDC clients (`outline`, `nextcloud`) and a test user (`testuser` / `test`) will be imported automatically.
2) Verify in the Keycloak Admin Console (http://localhost:8080) that the realm `acme`, both clients, and the test user exist.
3) Open Outline at http://localhost:8082 and click `Continue with Keycloak`. Log in with the test user. Outline is already configured for OIDC via environment variables.
4) Configure Nextcloud (http://localhost:8081) for OIDC:
   * Log in as `admin` / `admin`.
   * Go to `Apps` and install the app `Social Login` (use search).
   * Go to `Administration settings` → `Social login` and set up a new provider:
     * Custom OpenID Connect
     * Internal name: kc-masterclass (internal ID, cannot be changed later)
     * Title: Keycloak Masterclass (display name)
     * Authorize URL: `http://localhost:8080/realms/acme/protocol/openid-connect/auth`
     * Token URL: `http://keycloak:8080/realms/acme/protocol/openid-connect/token`
     * Userinfo URL: `http://keycloak:8080/realms/acme/protocol/openid-connect/userinfo`
     * Logout URL: `http://localhost:8080/realms/acme/protocol/openid-connect/logout`
     * Client ID: `nextcloud`
     * Client Secret: `nextcloud-secret`
     * Scope: `openid`
5) Save and log out of Nextcloud.
6) Test SSO: Open Nextcloud (http://localhost:8081) in a new tab and click `Login with Keycloak Masterclass`. Since you are already logged in to Keycloak through Outline, you should be logged in without entering your password again.
7) Log out from Nextcloud and check whether you are still logged in to Outline (we have a zombie session).
