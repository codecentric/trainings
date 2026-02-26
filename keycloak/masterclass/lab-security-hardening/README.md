# Lab: Security Hardening

## DE - Sicherheits-Review einer Keycloak-Konfiguration

### Szenario

Ein Kollege hat ein Keycloak für ein neues Projekt aufgesetzt. Bevor die Anwendung in Produktion geht, sollt ihr die Konfiguration auf Sicherheitsprobleme pruefen. Der Realm `insecure-realm` enthaelt **absichtlich** mehrere Fehlkonfigurationen, die gefunden und dokumentiert werden muessen.

### Umgebung starten

```bash
docker compose up
```

Keycloak Admin-Konsole: http://localhost:8080
Login: `admin` / `admin`

Wechselt nach dem Login in den Realm **insecure-realm**.

### Aufgabe
Untersucht den Realm `insecure-realm` systematisch und findet so viele Sicherheitsprobleme wie möglich. Dokumentiert fuer jedes Problem:

1. **Was?** - Was genau ist das Problem?
2. **Warum?** - Welches Risiko entsteht dadurch?
3. **Fix** - Wie wuerde man es beheben?

### Bereiche zum Pruefen

Geht die folgenden Bereiche in der Admin-Konsole systematisch durch:

- [ ] **Realm Settings > General** - Grundlegende Realm-Einstellungen
- [ ] **Realm Settings > Login** - Registrierung und Login-Optionen
- [ ] **Realm Settings > Login** - Email-Verifikation
- [ ] **Realm Settings > Sessions** - Session-Timeouts
- [ ] **Realm Settings > Tokens** - Token-Lifetimes
- [ ] **Realm Settings > Security Defenses** - Brute Force, Headers
- [ ] **Authentication > Policies > Password Policy** - Passwort-Anforderungen
- [ ] **Realm Settings > Events** - Event-Logging
- [ ] **Authentication > Required Actions** - Welche Aktionen sind fuer neue User vorgeschrieben?
- [ ] **Authentication > Flows** - Ist ein zweiter Faktor konfiguriert?
- [ ] **Clients** - Konfiguration aller Clients pruefen (Redirect URIs, Flows, Scopes, Web Origins) [service-account-client, webapp]
- [ ] **Users** - Benutzer und ihre Rollen pruefen

### Hinweise

- Achtet besonders auf Einstellungen, die in einer Produktionsumgebung anders sein sollten als in einer Entwicklungsumgebung.
- Vergleicht die Client-Konfigurationen: Welche Flows sind aktiviert? Sind die Redirect-URIs eingeschraenkt?
- Prueft, ob das Prinzip der minimalen Rechte (Least Privilege) eingehalten wird.
- Denkt an Token-Laufzeiten: Was passiert, wenn ein Token gestohlen wird?
- Schaut euch die Security Headers an - schuetzen sie vor gaengigen Angriffen?
- Gibt es eine Password Policy? Wenn ja, prueft alle Einstellungen genau - nicht nur ob eine existiert, sondern was sie tut.
- Gibt es einen zweiten Faktor? Besonders fuer privilegierte Accounts?
- Welche Origins duerfen Cross-Origin-Requests machen (CORS)?


---

## EN - Security Review of a Keycloak Configuration

### Scenario

A colleague has set up a Keycloak instance for a new project. Before the application goes to production, you need to review the configuration for security issues. The realm `insecure-realm` contains **intentional** misconfigurations that need to be found and documented.

### Start the environment

```bash
docker compose up
```

Keycloak Admin Console: http://localhost:8080
Login: `admin` / `admin`

After login, switch to the **insecure-realm**.

### Task

Systematically examine the `insecure-realm` and find as many security issues as possible. For each issue, document:

1. **What?** - What exactly is the problem?
2. **Why?** - What risk does it create?
3. **Fix** - How would you remediate it?

### Areas to review

Go through the following areas in the Admin Console systematically:

- [ ] **Realm Settings > General** - Basic realm settings
- [ ] **Realm Settings > Login** - Registration and login options
- [ ] **Realm Settings > Email** - Email verification
- [ ] **Realm Settings > Sessions** - Session timeouts
- [ ] **Realm Settings > Tokens** - Token lifetimes
- [ ] **Realm Settings > Security Defenses** - Brute force, headers
- [ ] **Authentication > Policies > Password Policy** - Password requirements
- [ ] **Realm Settings > Events** - Event logging
- [ ] **Authentication > Required Actions** - Which actions are required for new users?
- [ ] **Authentication > Flows** - Is a second factor configured?
- [ ] **Clients** - Review all client configurations (redirect URIs, flows, scopes, web origins) [service-account-client, webapp]
- [ ] **Users** - Review users and their roles

### Hints

- Pay special attention to settings that should differ between development and production environments.
- Compare client configurations: Which flows are enabled? Are redirect URIs restricted?
- Check whether the principle of least privilege is followed.
- Think about token lifetimes: What happens if a token is stolen?
- Look at the security headers - do they protect against common attacks?
- Is there a password policy? If so, check all settings carefully - not just whether one exists, but what it does.
- Is there a second factor? Especially for privileged accounts?
- Which origins are allowed to make cross-origin requests (CORS)?
