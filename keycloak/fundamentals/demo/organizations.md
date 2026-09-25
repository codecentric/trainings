# Demo: Keycloak Organizations

## DE

**Ziel der Demo:** Erstes Verständnis von Organizations

**Umgebung:** LAB 2.2

### Hintergrund: Multi-Tenancy

Multi-Tenancy → Zugriff auf eine Instanz einer Software oder Plattform mehreren unabhängigen Nutzern (Mandanten) gleichzeitig zur Verfügung zu stellen. Nicht jeder Nutzerkreis bekommt eine eigene, vollständige Instanz, also gemeinsame Nutzung der Infrastruktur. Herausforderung ist Datenisolation und Trennung der Konfiguration.

Varianten:

- **Jeder Mandant eine eigene Keycloak-Instanz** → Sehr aufwendig und hoher Ressourcenbedarf
- **Jeder Mandant ein eigener Realm** → Viel Boilerplate, viele Duplizierungen, skaliert aktuell nur bis wenige 100 Realms
- **Jeder Mandant eine Organization in einem Realm** → Extra geschaffenes Konstrukt für Mandantenfähigkeit, da User, Clients, Flows, Rollen, Keys, Configs etc. geteilt werden

### Setup

1. **Neuen Realm anlegen:** `Organizations`
2. **Realm settings → General → Organizations enablen**
3. Im Hauptmenü erscheint jetzt der Menüpunkt `Organizations`

### Organization 1

4. **Create organization:** `warner-bros-entertainment` (wird dann die Org-ID sein)
   - **Domain:** `warner-bros.com` (entspricht E-Mail der Nutzer)
   - **Domain:** `acme-labs.com`
5. **In der angelegten Org die Tabs zeigen:**
   - `Settings`
   - `Attributes` → Key/Value
   - `Members` → User verwalten
   - `Identity Broker` → Login delegieren möglich (SSO vom Kunden)
6. **User anlegen:** `bugs.bunny@warner-bros.com`
   - Über den Reiter `Organizations` den Nutzer zur Org hinzufügen
7. **User anlegen:** `pinky@acme-labs.com`
   - Die Zuordnung über die Organization zeigen (durch die E-Mail-Domain)

### Organization 2

8. **Create organization:** `Initech` (aus Alles Routine / Office Space)
   - **Domain:** `initech.com` (entspricht E-Mail der Nutzer)
9. **User anlegen:** `peter.gibbons@initech.com`
   - Zuordnung zur Orga

### Hinweis

- Die User sind immer noch Realm-User! Über die Membership-Entity wird die Zugehörigkeit zu Organizations realisiert.
- User können mehreren Organizations zugeordnet sein, aber nur mit ihrer E-Mail-Domain werden sie einer Primär-Organization zugeordnet bzw. identifiziert.
- **User `pinky` auch zu `Initech` hinzufügen**

### Login → Identity First

Da wir Authentication Flows noch nicht hatten, nur der Login über die Account Console:

10. **Account Console öffnen**
11. **`bugs.bunny` einloggen** (Password-Form erscheint erst im zweiten Schritt, da ggf. ein externer IdP konfiguriert sein könnte)
12. In der Account Console gibt es `Organizations` → Zuordnung anschauen

### Access-Token zeigen

13. `Clients` → `account` → `Client scopes` → `Evaluate`
    - User `bugs.bunny` auswählen
    - `Generated Access Token` anschauen
    - **Scope Parameter `organization` hinzufügen**
    - Access Token nochmal anschauen → Organization ist enthalten
    - Auf User `pinky` wechseln und Access Token anschauen
14. Im Client Scope auch nochmal den **Organization-Mapper** zeigen

### Zusammenfassung

- Mit Organizations können wir Nutzer anhand ihrer Identität Mandanten zuordnen
- Die Zuordnung ist über den Scope im Token abgebildet
- Eine Organization kann innerhalb eines Realms eigene Attribute erhalten
- Es besteht die Option, einen externen IdP einzubinden (z.B. SSO des Kunden)
- Organizations skalieren im Gegensatz zu Realms
- Organization-Admins können Mitglieder einer Organization verwalten, benötigt weitere Konfigurationen

**Demo Ende** → Idee, was Organizations sind, sollte gezeigt sein

## EN

**Goal of the demo:** First understanding of Organizations

**Environment:** LAB 2.2

### Background: Multi-Tenancy

Multi-tenancy → providing several independent users (tenants) with simultaneous access to a single instance of a software or platform. Not every group of users gets its own complete instance — the infrastructure is shared. The challenge is data isolation and separating configuration.

Variants:

- **Each tenant gets its own Keycloak instance** → Very expensive and high resource requirements
- **Each tenant gets its own realm** → Lots of boilerplate, lots of duplication, currently only scales to a few hundred realms
- **Each tenant gets one organization within a realm** → Purpose-built construct for multi-tenancy, since users, clients, flows, roles, keys, configs, etc. are shared

### Setup

1. **Create a new realm:** `Organizations`
2. **Enable Organizations:** `Realm settings` → `General` → `Organizations`
3. The `Organizations` menu item now appears in the main menu

### Organization 1

4. **Create organization:** `warner-bros-entertainment` (this will become the Org ID)
   - **Domain:** `warner-bros.com` (matches the users' email domain)
   - **Domain:** `acme-labs.com`
5. **Show the tabs of the created organization:**
   - `Settings`
   - `Attributes` → key/value
   - `Members` → manage users
   - `Identity Broker` → login delegation possible (customer SSO)
6. **Create user:** `bugs.bunny@warner-bros.com`
   - Add the user to the organization via the `Organizations` tab
7. **Create user:** `pinky@acme-labs.com`
   - Show the assignment via the organization (through the email domain)

### Organization 2

8. **Create organization:** `Initech` (from Office Space)
   - **Domain:** `initech.com` (matches the users' email domain)
9. **Create user:** `peter.gibbons@initech.com`
   - Assign to the organization

### Note

- The users are still realm users! Membership in organizations is realized through the membership entity.
- Users can belong to multiple organizations, but they are only assigned to (and identified by) a primary organization via their email domain.
- **Also add user `pinky` to `Initech`**

### Login → Identity First

Since we haven't covered authentication flows yet, only the login via the account console:

10. **Open the account console**
11. **Log in as `bugs.bunny`** (the password form only appears in the second step, since an external IdP could potentially be configured)
12. In the account console there is an `Organizations` section → show the membership

### Inspect the access token

13. `Clients` → `account` → `Client scopes` → `Evaluate`
    - Select user `bugs.bunny`
    - Show the `Generated Access Token`
    - **Add `organization` as scope parameter**
    - Look at the access token again → the organization is now contained in it
    - Switch to user `pinky` and show the access token
14. Also show the **organization mapper** in the client scope

### Summary

- With organizations, we can assign users to tenants based on their identity
- The assignment is reflected in the token via the scope
- An organization can have its own attributes within a realm
- There is the option to integrate an external IdP (e.g. the customer's SSO)
- Organizations scale, in contrast to realms
- Organization admins can manage the members of an organization, but this requires additional configuration

**End of demo** → the concept of what organizations are should now be clear
