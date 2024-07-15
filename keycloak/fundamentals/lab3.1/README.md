# Lab 3.1

1) Startet das Lab via `docker compose up`.
2) Legt einen Realm `proxy` sowie darin einen Client `proxy` an, der die Redirect URL `https://localhost:4180/*` akzeptiert.
3) Legt einen Benutzer vollständig an.
4) Geht in die Client Konfiguration von `proxy` in den Tab `Client scopes` und dort auf `proxy-dedicated`. Nutzt `Configure a new mapper` -> `Audience` mit dem Namen `proxy` und der Included Client Audience `proxy`.
5) Stoppt die Umgebung mit CTRL + C und kommentiert in die `docker-compose.yaml` den `oauth2-proxy` ein (`#` entfernen).
6) Setzt die folgenden Werte in der Datei. Die Email Domain sollte der Email Domain eures angelegten Benutzers entsprechen:
   ```
   OAUTH2_PROXY_UPSTREAMS: http://nginx:80/
   OAUTH2_PROXY_OIDC_ISSUER_URL: http://keycloak:8080/realms/proxy
   OAUTH2_PROXY_EMAIL_DOMAINS: "codecentric.de"
   ```
7) Funktion des OAuth Proxies prüfen: http://localhost:4180/

Zusatzaufgabe: Versucht über eine Environmentvariable des OAuth Proxies PKCE zu aktivieren.