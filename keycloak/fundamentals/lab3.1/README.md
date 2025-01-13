# Lab 3.1

## DE

1) Startet das Lab via `docker compose up`.
2) Legt einen Realm `proxy` sowie darin einen Client `proxy` an, der die Redirect URL `http://localhost:4180/*` akzeptiert.
3) Legt einen Benutzer vollständig an.
4) Geht in die Client Konfiguration von `proxy` in den Tab `Client scopes` und dort auf `proxy-dedicated`. Nutzt `Configure a new mapper` -> `Audience` mit dem Namen `proxy` und der Included Client Audience `proxy`.
5) Stoppt die Umgebung mit CTRL + C und kommentiert in die `docker-compose.yaml` den `oauth2-proxy` ein (`#` entfernen).
6) Setzt die unten stehenden Values in der Datei. Die Email Domain sollte der Email Domain eures angelegten Benutzers entsprechen. Füllt auch die anderen Platzhalter (OAUTH2_PROXY_CLIENT_ID/OAUTH2_PROXY_CLIENT_SECRET).
7) Funktion des OAuth Proxies prüfen: http://localhost:4180/

Zusatzaufgabe: Versucht über eine Environmentvariable des OAuth Proxies PKCE zu aktivieren.

## EN

1) Start the Lab via `docker compose up`.
2) Create a realm `proxy` and a client `proxy` that accepts the redirect URL `http://localhost:4180/*`.
3) Create a complete user.
4) Go to the client configuration of `proxy` in the tab `Client scopes` and there to `proxy-dedicated`. Use `Configure a new mapper` -> `Audience` with the name `proxy` and the Included Client Audience `proxy`.
5) Stop the environment with CTRL + C and decomment the `oauth2-proxy` in the `docker-compose.yaml` (remove `#`).
6) Set the values below in the file. The email domain should correspond to the email domain of your created user. Fill the other placeholders as well (OAUTH2_PROXY_CLIENT_ID/OAUTH2_PROXY_CLIENT_SECRET).
7) Check the function of the OAuth proxy: http://localhost:4180/

Additional task: Try to activate PKCE via an environment variable of the OAuth proxy.

## Values
```
OAUTH2_PROXY_UPSTREAMS: http://nginx:80/
OAUTH2_PROXY_OIDC_ISSUER_URL: http://host.docker.internal:8080/realms/proxy
OAUTH2_PROXY_EMAIL_DOMAINS: "codecentric.de"
```

### DE Hinweis
Die Adressierung des Docker-Hosts über host.docker.internal sollte unter Windows und macOS funktionieren. Unter Linux könnte es sein, dass 172.17.0.1 verwendet werden muss. Wenn auch das nicht hilft, kann es helfen, alle Container auf dem Netzwerkhost laufen zu lassen und localhost zu verwenden.

### EN Note
Adressing the Docker Host via host.docker.internal should work on Windows and macOS. If using Linux, you might have to use 172.17.0.1 instead. If that doesn't help either, it might help to run all containers on the network host and use localhost.
