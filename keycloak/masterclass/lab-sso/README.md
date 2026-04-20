# Lab SSO

## DE

Ziel: Ihr lernt, wie Single Sign-On (SSO) in der Praxis funktioniert, indem ihr zwei Anwendungen (Outline und Nextcloud) über Keycloak verbindet und das SSO-Verhalten sowie das Session-Management beobachtet.

1) Startet das Lab via `docker compose up`. Der Realm `acme` mit zwei OIDC-Clients (`outline`, `nextcloud`) und einem Testbenutzer (`testuser` / `test`) wird automatisch importiert.
2) Prüft in der Keycloak Admin Console (http://localhost:8080), ob der Realm `acme` sowie die beiden Clients und der Testbenutzer vorhanden sind.
3) In den `acme` Realm settings/Tokens -> Access Token Lifespan setzt ihr den Wert auf 15 Minuten. (damit unser Access Token für diese Übung nicht so schnell abläuft) 
4) Öffnet Outline unter http://localhost:8082, ihr solltet in der Regel direkt zum Keycloak weitergeleitet werden. Loggt euch mit dem Testbenutzer ein. Outline ist bereits via Environmentvariablen für OIDC konfiguriert.
5) Konfiguriert nun Nextcloud (http://localhost:8081) für OIDC (Hinweis: manchmal sind die Übersetzungen nicht selbstsprechend ;) ):
   * Loggt euch als `admin` / `admin` ein.
   * Geht zu `Apps` und installiert die App `Social Login` (Suche benutzen).
   * Geht zu `Verwaltung` (Administration settings) → `Social login` und richtet einen neuen Provider ein:
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
6) Speichern und aus der Nextcloud ausloggen.
7) Testet SSO: Öffnet Nextcloud (http://localhost:8081) in einem neuen Tab und klickt auf `Anmelden/Login mit Keycloak Masterclass`. Da ihr bereits über Outline bei Keycloak eingeloggt seid, solltet ihr ohne erneute Passworteingabe eingeloggt werden.
8) Schaut euch die Sessions in der Admin Console für den Realm `acme` an.
9) Loggt euch in der Nextcloud aus und prüft die Sessions in der Admin Console für den Realm `acme` --> die SSO-Session sollte weg sein.
10) Prüft, ob ihr noch in Outline eingeloggt seid -> wir haben eine Zombie Session
11) Schaut euch die Sessions in der Admin Console für den Realm `acme` an.


`Continue with Keycloak`

## EN

Goal: You will learn how Single Sign-On (SSO) works in practice by connecting two applications (Outline and Nextcloud) through Keycloak and observing SSO behavior and session management.

1) Start the lab via `docker compose up`. The realm `acme` with two OIDC clients (`outline`, `nextcloud`) and a test user (`testuser` / `test`) will be imported automatically.
2) Verify in the Keycloak Admin Console (http://localhost:8080) that the realm `acme`, both clients, and the test user exist.
3) In the `acme` realm settings/Tokens -> Access Token Lifespan, set the value to 15 minutes. (so that our access token doesn't expire too quickly for this exercise)
4) Open Outline at http://localhost:8082 — you should usually be redirected to Keycloak automatically. Log in with the test user. Outline is already configured for OIDC via environment variables.
5) Configure Nextcloud (http://localhost:8081) for OIDC (hint: sometimes the translations are not self-explanatory ;) ):
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
6) Save and log out of Nextcloud.
7) Test SSO: Open Nextcloud (http://localhost:8081) in a new tab and click `Login with Keycloak Masterclass`. Since you are already logged in to Keycloak through Outline, you should be logged in without entering your password again.
8) Check the sessions in the Admin Console for the `acme` realm.
9) Log out from Nextcloud and check the sessions in the Admin Console for the `acme` realm --> the SSO session should be gone.
10) Check whether you are still logged in to Outline -> we have a zombie session.
11) Check the sessions in the Admin Console for the `acme` realm.
