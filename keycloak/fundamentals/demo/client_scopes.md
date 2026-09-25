# Demo: Keycloak Client Scopes

## DE

**Ziel der Demo:** Die Gruppenzugehörigkeit auch im Token ausgeben

**Umgebung:** LAB 2.1

### Vorbereitung: Realm, Client, Gruppe und User anlegen

1. **Realm anlegen:** `scopedemo-realm`
2. **Client anlegen:** `scopedemo-client` (mit Defaults)
3. **Gruppe anlegen:** `scopedemo-group`
4. **User anlegen:** `scopedemo-user` mit Vor- und Nachname
   - `Email verified` aktivieren
   - Passwort `scopedemo-pass` setzen, `Temporary` deaktivieren
   - Über den Tab `Groups` im Userprofil den User der Gruppe `scopedemo-group` hinzufügen
   - Über die Links im Menü zeigen, dass unter `Groups` der User auch in der Gruppe erscheint

### Client Scope anlegen

5. **Client Scope anlegen:** `scopedemo-scope` (unter `Client scopes`) mit **Type = Optional**
   - `Include in token scope` aktivieren
6. **Mapper anlegen:** `Mappers` -> `Configure a new Mapper`
   - Typ: `Group Membership`
   - Name & Token Claim Name = `groups`
7. **Client Scope dem Client hinzufügen:** `scopedemo-client` -> `Client scopes` -> `scopedemo-scope` als **Optional** hinzufügen

### Token prüfen (Admin UI)

8. `Clients` -> `scopedemo-client` -> `Client scopes` -> `Evaluate`
   - `scopedemo-scope` als **Scope parameter** hinzufügen
   - `scopedemo-user` auswählen
   - `Generated Access Token` anzeigen und zeigen, dass `groups` darin enthalten ist
   - Scope Parameter entfernen und zeigen, dass `groups` weg ist

### Token prüfen (via API)

Ohne Scope Parameter — `groups` fehlt im Token:

```bash
curl \
  -d "client_id=scopedemo-client" \
  -d "username=scopedemo-user" \
  -d "password=scopedemo-pass" \
  -d "grant_type=password" \
  "http://localhost:8080/realms/scopedemo-realm/protocol/openid-connect/token"
```

Mit Scope Parameter — `groups` ist im Token enthalten:

```bash
curl \
  -d "client_id=scopedemo-client" \
  -d "username=scopedemo-user" \
  -d "password=scopedemo-pass" \
  -d "grant_type=password" \
  -d "scope=scopedemo-scope" \
  "http://localhost:8080/realms/scopedemo-realm/protocol/openid-connect/token"
```

## EN

**Goal of the demo:** Show group membership in the token

**Environment:** LAB 2.1

### Preparation: Create realm, client, group, and user

1. **Create realm:** `scopedemo-realm`
2. **Create client:** `scopedemo-client` (with defaults)
3. **Create group:** `scopedemo-group`
4. **Create user:** `scopedemo-user` with first and last name
   - Enable `Email verified`
   - Set password `scopedemo-pass`, disable `Temporary`
   - Add the user to the group `scopedemo-group` via the `Groups` tab in the user profile
   - Use the links in the menu to show that under `Groups` the user also appears in the group

### Create the client scope

5. **Create client scope:** `scopedemo-scope` (under `Client scopes`) with **Type = Optional**
   - Enable `Include in token scope`
6. **Create mapper:** `Mappers` -> `Configure a new Mapper`
   - Type: `Group Membership`
   - Name & Token Claim Name = `groups`
7. **Add the client scope to the client:** `scopedemo-client` -> `Client scopes` -> add `scopedemo-scope` as **Optional**

### Inspect the token (Admin UI)

8. `Clients` -> `scopedemo-client` -> `Client scopes` -> `Evaluate`
   - Add `scopedemo-scope` as **scope parameter**
   - Select `scopedemo-user`
   - Show `Generated Access Token` and demonstrate that `groups` is contained in it
   - Remove the scope parameter and show that `groups` is gone

### Inspect the token (via API)

Without scope parameter — `groups` is missing from the token:

```bash
curl \
  -d "client_id=scopedemo-client" \
  -d "username=scopedemo-user" \
  -d "password=scopedemo-pass" \
  -d "grant_type=password" \
  "http://localhost:8080/realms/scopedemo-realm/protocol/openid-connect/token"
```

With scope parameter — `groups` is contained in the token:

```bash
curl \
  -d "client_id=scopedemo-client" \
  -d "username=scopedemo-user" \
  -d "password=scopedemo-pass" \
  -d "grant_type=password" \
  -d "scope=scopedemo-scope" \
  "http://localhost:8080/realms/scopedemo-realm/protocol/openid-connect/token"
```
