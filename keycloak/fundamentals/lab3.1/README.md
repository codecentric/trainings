# Lab 3.1

## DE

1) Startet das Lab via `docker compose up`.
2) Legt einen Realm `proxy` sowie darin einen Client `proxy` an, der die Redirect URL `https://localhost:4180/*` akzeptiert.
3) Legt einen Benutzer vollständig an.
4) Geht in die Client Konfiguration von `proxy` in den Tab `Client scopes` und dort auf `proxy-dedicated`. Nutzt `Configure a new mapper` -> `Audience` mit dem Namen `proxy` und der Included Client Audience `proxy`.
5) Stoppt die Umgebung mit CTRL + C und kommentiert in die `docker-compose.yaml` den `oauth2-proxy` ein (`#` entfernen).
6) Setzt die unten stehenden Values in der Datei. Die Email Domain sollte der Email Domain eures angelegten Benutzers entsprechen.
7) Funktion des OAuth Proxies prüfen: http://localhost:4180/

Zusatzaufgabe: Versucht über eine Environmentvariable des OAuth Proxies PKCE zu aktivieren.

## EN

1) Start the Lab via `docker compose up`.
2) Create a realm `proxy` and a client `proxy` that accepts the redirect URL `https://localhost:4180/*`.
3) Create a complete user.
4) Go to the client configuration of `proxy` in the tab `Client scopes` and there to `proxy-dedicated`. Use `Configure a new mapper` -> `Audience` with the name `proxy` and the Included Client Audience `proxy`.
5) Stop the environment with CTRL + C and decomment the `oauth2-proxy` in the `docker-compose.yaml` (remove `#`).
6) Set the values below in the file. The email domain should correspond to the email domain of your created user.
7) Check the function of the OAuth proxy: http://localhost:4180/

Additional task: Try to activate PKCE via an environment variable of the OAuth proxy.

## Values
```
OAUTH2_PROXY_UPSTREAMS: http://nginx:80/
OAUTH2_PROXY_OIDC_ISSUER_URL: http://keycloak:8080/realms/proxy
OAUTH2_PROXY_EMAIL_DOMAINS: "codecentric.de"
```