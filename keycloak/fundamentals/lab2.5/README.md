# Lab 2.5 – Token Exchange & Downscoping

## DE

1) Startet das Lab via `docker compose up`. Das Realm `labrealm` (Clients, User, Mapper) wird automatisch importiert – schaut euch die Datei `./config/labrealm.json` an, um zu sehen, was konfiguriert wurde.
2) Loggt euch in die Admin Console ein (http://localhost:8080, `admin`/`admin`) und verschafft euch einen Überblick im Realm `labrealm`:
   - Client `labclient`: confidential Client (**Client authentication** an), **Direct access grants** an, **Standard token exchange** an (Settings → Capability config)
   - Die beiden Audience-Mapper am `labclient` (Client scopes → `labclient-dedicated` → Mappers)
   - User `labuser`
3) Ruft die Token für `labuser` ab (s. Code 1) und prüft den **Access Token** unter jwt.io: Die `aud`-Claim enthält `backend-a` und `backend-b`.
4) Tauscht den Access Token gegen einen auf `backend-a` heruntergestuften ("downscoped") Token ein (s. Code 2). Achtet darauf, dass sich `labclient` dabei per **Client Secret** authentifizieren muss.
5) Prüft den erhaltenen Access Token unter jwt.io: Die `aud`-Claim enthält nur noch `backend-a`. Die `sub`-Claim gehört weiterhin zum `labuser` — durch den Token Exchange ändert sich also **nicht** die Identität, sondern nur die Zielgruppe/Authorisierung.
6) Optional: Was passiert, wenn ihr die `-u`-Client-Authentifizierung weglasst? Und was, wenn ihr eine Audience anfragt, die im Token nicht verfügbar ist (z. B. ein zusätzlich angelegter `backend-c` ohne Mapper)?

## EN

1) Start the lab via `docker compose up`. The realm `labrealm` (clients, user, mappers) is imported automatically – take a look at the file `./config/labrealm.json` to see what has been configured.
2) Log into the admin console (http://localhost:8080, `admin`/`admin`) and get an overview of the realm `labrealm`:
   - Client `labclient`: confidential client (**Client authentication** on), **Direct access grants** on, **Standard token exchange** on (Settings → Capability config)
   - The two audience mappers on `labclient` (Client scopes → `labclient-dedicated` → Mappers)
   - User `labuser`
3) Retrieve the tokens for `labuser` (see code 1) and check the **access token** under jwt.io: The `aud` claim contains `backend-a` and `backend-b`.
4) Exchange the access token for a token downscoped to `backend-a` (see code 2). Note that `labclient` has to authenticate with its **client secret**.
5) Check the received access token under jwt.io: The `aud` claim only contains `backend-a` anymore. The `sub` claim still belongs to `labuser` — the token exchange does **not** change the identity, only the audience/authorization.
6) Optional: What happens if you omit the `-u` client authentication? And what if you request an audience that is not available in the token (e.g. an additionally created `backend-c` without a mapper)?

## Code 1

```
curl \
-d "client_id=labclient" \
-d "client_secret=labclient-secret" \
-d "username=labuser" \
-d "password=labuser" \
-d "grant_type=password" \
"http://localhost:8080/realms/labrealm/protocol/openid-connect/token"
```

## Code 2

```
curl \
-u "labclient:labclient-secret" \
-d "grant_type=urn:ietf:params:oauth:grant-type:token-exchange" \
-d "subject_token=<ACCESS-TOKEN>" \
-d "subject_token_type=urn:ietf:params:oauth:token-type:access_token" \
-d "audience=backend-a" \
"http://localhost:8080/realms/labrealm/protocol/openid-connect/token"
```

## Background

Token Exchange ist die RFC 8693-konforme, vollständig unterstützte Implementierung und seit Keycloak 26 standardmäßig aktiviert. Über den `audience`-Parameter wird der Token auf die minimal nötige Zielgruppe (**Least Privilege**) heruntergestuft. Das ist das typische Muster für Microservice-Architekturen: ein Gateway tauscht den User-Token gegen einen Token ein, der nur noch für den jeweils aufzurufenden Service gültig ist.

English: Token exchange is the RFC 8693-compliant, fully supported implementation and enabled by default since Keycloak 26. The `audience` parameter downscopes the token to the minimum required audience (least privilege) — the typical pattern for microservice architectures, where a gateway exchanges the user token for one valid only for the service it is about to call.
