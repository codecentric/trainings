# Lab 3.1 – OAuth2 Proxy

## DE

### Ziel

In diesem Lab wird ein OAuth2 Proxy als Reverse Proxy vor eine statische Webseite geschaltet, um die Anwendung mit Single Sign-On abzusichern, ohne dass die Anwendung selbst etwas von OAuth2/OIDC wissen muss. Du lernst, wie der Proxy als OAuth2-Client an Keycloak angebunden wird, welche Rolle der Audience-Mapper für die Token-Validierung spielt und wie der Authorization Code Flow mit Redirects in der Praxis abläuft.

1) Startet das Lab via `docker compose up`.
2) Legt einen Realm `proxy` sowie darin einen Client `proxy` mit Client Auth an, der die Redirect URL `http://localhost:4180/*` akzeptiert. Kopiert euch das Client Secret.
3) Legt einen Benutzer vollständig an.
4) Geht in die Client Konfiguration von `proxy` in den Tab `Client scopes` und dort auf `proxy-dedicated`. Nutzt `Configure a new mapper` -> `Audience` mit dem Namen `proxy` und der Included Client Audience `proxy`.
5) Stoppt die Umgebung mit CTRL + C und kommentiert in die `docker-compose.yaml` den `oauth2-proxy` ein (`#` entfernen).
6) Setzt die unten stehenden Values in der Datei für `oauth2-proxy`. Die Email Domain sollte der Email Domain eures angelegten Benutzers entsprechen.
7) Starte die Umgebung neu
8) Funktion des OAuth Proxies prüfen: http://localhost:4180/

Zusatzaufgabe: Versucht über eine Environmentvariable des OAuth Proxies PKCE zu aktivieren.

## EN

### Goal

In this lab, an OAuth2 proxy is placed as a reverse proxy in front of a static website in order to secure the application with single sign-on without the application itself needing to know anything about OAuth2/OIDC. You will learn how the proxy is connected to Keycloak as an OAuth2 client, which role the audience mapper plays in token validation and how the authorization code flow with redirects works in practice.

1) Start the Lab via `docker compose up`.
2) Create a realm `proxy` and a client `proxy` with Client Auth that accepts the redirect URL `http://localhost:4180/*`. Copy the client secret.
3) Create a complete user.
4) Go to the client configuration of `proxy` in the tab `Client scopes` and there to `proxy-dedicated`. Use `Configure a new mapper` -> `Audience` with the name `proxy` and the Included Client Audience `proxy`.
5) Stop the environment with CTRL + C and decomment the `oauth2-proxy` in the `docker-compose.yaml` (remove `#`).
6) Set the values below in the file. The email domain should correspond to the email domain of your created user.
7) Check the function of the OAuth proxy: http://localhost:4180/

Additional task: Try to activate PKCE via an environment variable of the OAuth proxy.

## Values
```
OAUTH2_PROXY_CLIENT_ID: <your-client-id>
OAUTH2_PROXY_CLIENT_SECRET: <your-client-secret>
OAUTH2_PROXY_EMAIL_DOMAINS: "codecentric.de"
```
