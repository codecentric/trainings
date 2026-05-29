# Kerberos + LDAP + Keycloak Playground

Eine vollständig in sich geschlossene Docker-Compose-Umgebung zum Lernen und Experimentieren mit MIT Kerberos, OpenLDAP und Keycloaks SPNEGO-Benutzer-Federation.

Alles läuft lokal — keine externen Dienste, keine DNS-Konfiguration erforderlich.

## Inhalt

- **MIT Kerberos KDC** — stellt Tickets für den Realm `EXAMPLE.COM` aus
- **OpenLDAP** — Benutzerverzeichnis; nur hier eingetragene Benutzer dürfen sich per Kerberos anmelden
- **Keycloak** — LDAP-Benutzer-Federation mit integrierter Kerberos/SPNEGO-Unterstützung
- **kerberos-client** — Debian-Shell-Container zum Testen von `kinit` und `ldapsearch`

## Voraussetzungen

| Anforderung | Hinweis |
|-------------|---------|
| Docker + Docker Compose v2 | Mit `docker compose version` prüfen |
| Port 88 frei auf dem Host | KDC ist unter localhost:88 erreichbar |
| Port 389 frei auf dem Host | LDAP ist unter localhost:389 erreichbar |
| Port 8080 frei auf dem Host | Keycloak Admin-UI |

**Für `kinit` direkt auf dem Host (optional — alternativ den `kerberos-client`-Container nutzen):**

| Betriebssystem | Installation |
|----------------|-------------|
| Debian/Ubuntu | `sudo apt install krb5-user ldap-utils` |
| macOS | Kerberos ist eingebaut; `brew install openldap` für `ldapsearch` |
| Windows | MIT Kerberos for Windows oder WSL |

**Für Browser-SPNEGO:**

- Firefox muss als **natives Paket** installiert sein (deb, rpm, Homebrew) — nicht über Snap oder Flatpak, da diese den Browser in einer Sandbox ohne Zugriff auf die GSSAPI-Systembibliotheken ausführen
- Chrome/Chromium funktioniert über eine Policy-Datei (siehe [Browser-SPNEGO-Konfiguration](#browser-spnego-konfiguration))

## Die Grundidee

Kerberos beweist *wer du bist*. LDAP definiert *wer Zugang hat*. Keycloak verbindet beides.

```
Kerberos-Ticket gültig ✓  +  Benutzer in LDAP vorhanden ✓  →  angemeldet
Kerberos-Ticket gültig ✓  +  Benutzer NICHT in LDAP      ✗  →  abgewiesen
```

So wird verhindert, dass Kerberos-Principals, die im KDC existieren, aber nie im Verzeichnis provisioniert wurden, Zugang erhalten.

## Wie SPNEGO funktioniert

```
1. kinit
   Du → KDC:        "Ich bin alice, gib mir ein TGT"
   KDC → Du:        TGT (verschlüsselt, lokal gecacht unter /tmp/krb5cc_<uid>)

2. Browser öffnet eine App
   App → Keycloak:  Weiterleitung zur Anmeldung

3. SPNEGO-Aushandlung
   Keycloak → Browser:   WWW-Authenticate: Negotiate
   Browser  → KDC:       "Gib mir ein Service-Ticket für HTTP/localhost"
   Browser  → Keycloak:  Authorization: Negotiate <ticket>

4. Keycloak prüft Ticket + LDAP
   → Entschlüsselt das Ticket mit dem Keytab
   → Sucht alice in LDAP (ou=users,dc=example,dc=com)
   → Gefunden: Keycloak-Benutzer wird angelegt/aktualisiert, OIDC-Session ausgestellt
   → Nicht gefunden: Authentifizierung abgelehnt
```

## Architektur

```
┌──────────────────────────────────────────────────────────────┐
│  Docker Compose (localhost)                                  │
│                                                              │
│  ┌──────────────┐  Keytab (geteiltes Volume)                │
│  │  kerberos    │ ─────────────────────────────────────┐    │
│  │  MIT KDC     │                                      │    │
│  │  Port 88     │                                      ▼    │
│  └──────────────┘                         ┌────────────────┐ │
│                                           │   keycloak     │ │
│  ┌──────────────┐  ldap://openldap:389    │   Port 8080    │ │
│  │  openldap    │ ◄─────────────────────  │   LDAP-Fed.    │ │
│  │  Port 389    │                         │   + Kerberos   │ │
│  └──────────────┘                         └────────────────┘ │
│                                                              │
│  ┌──────────────┐                                            │
│  │ krb-client   │  kinit / ldapsearch (Test-Shell)          │
│  └──────────────┘                                            │
└──────────────────────────────────────────────────────────────┘
        ▲  Port 88                    ▲  Port 8080
        │  Port 389                   │
        └──────────── Host ───────────┘
```

## Schnellstart

```bash
cp .env.example .env
docker compose up --build
```

Warten bis alle drei Dienste healthy sind (~60–90 s beim ersten Start):
```bash
docker compose ps
```

| Dienst | URL / Port | Zugangsdaten |
|--------|-----------|--------------|
| Keycloak Admin | http://localhost:8080 | admin / admin |
| KDC | localhost:88 | — |
| kadmind | localhost:749 | admin/admin@EXAMPLE.COM / adminpassword |
| LDAP | localhost:389 | cn=admin,dc=example,dc=com / adminpassword |

## Benutzer und Principals

### LDAP-Benutzer (`ou=users,dc=example,dc=com`)

| uid | Passwort | Hinweis |
|-----|----------|---------|
| `alice` | `alice` | Wird beim ersten Login automatisch in Keycloak angelegt |

### Kerberos-Principals (`EXAMPLE.COM`)

| Principal | Passwort | Zweck |
|-----------|----------|-------|
| `admin/admin@EXAMPLE.COM` | `adminpassword` | KDC-Admin |
| `alice@EXAMPLE.COM` | `alice` | Testbenutzer |
| `HTTP/localhost@EXAMPLE.COM` | (zufälliger Schlüssel) | Keycloak SPNEGO-Dienst |

Alice ist in **beiden** Systemen eingetragen — LDAP und Kerberos — und kann sich daher per SPNEGO anmelden.
Einen Benutzer nur in einem der beiden Systeme anzulegen zeigt das Zugangskontrollverhalten.

## Kerberos-Authentifizierung testen

### Option A — im Docker-Container (keine Host-Installation nötig)

```bash
docker compose exec kerberos-client bash

# Kerberos testen
kinit alice@EXAMPLE.COM     # Passwort: alice
klist                        # TGT bestätigen

# LDAP testen
ldapsearch -x -H ldap://openldap:389 \
  -b "ou=users,dc=example,dc=com" \
  -D "cn=admin,dc=example,dc=com" \
  -w adminpassword \
  "(uid=alice)"
```

### Option B — direkt auf dem Host

```bash
# Debian/Ubuntu
sudo apt install -y krb5-user ldap-utils

# macOS (Kerberos eingebaut, ldap-utils via brew)
brew install openldap

sudo cp krb5-host.conf /etc/krb5.conf
kinit alice@EXAMPLE.COM     # Passwort: alice
klist

ldapsearch -x -H ldap://localhost:389 \
  -b "ou=users,dc=example,dc=com" \
  -D "cn=admin,dc=example,dc=com" \
  -w adminpassword \
  "(uid=alice)"
```

## Browser-SPNEGO-Konfiguration

> **Hinweis:** Firefox muss als natives Paket installiert sein (deb, rpm, Homebrew) — nicht über Snap oder Flatpak. Diese führen den Browser in einer Sandbox aus, die keinen Zugriff auf die GSSAPI-Systembibliotheken hat. Der Negotiate-Header wird dann stillschweigend ignoriert.

**Firefox** — `about:config` öffnen:
```
network.negotiate-auth.trusted-uris  →  localhost
```

**Chrome/Chromium:**
```bash
sudo mkdir -p /etc/opt/chrome/policies/managed
sudo tee /etc/opt/chrome/policies/managed/kerberos.json <<EOF
{
  "AuthServerAllowlist": "localhost",
  "AuthNegotiateDelegateAllowlist": "localhost"
}
EOF
```

Browser neu starten, dann:

1. `kinit alice@EXAMPLE.COM`
2. http://localhost:8080/realms/kerberos-demo/account öffnen
3. Alice ist ohne Passwortabfrage angemeldet

Zur Überprüfung in den DevTools → Netzwerk:
- Die Keycloak-Weiterleitung enthält `WWW-Authenticate: Negotiate`
- Die darauffolgende Anfrage enthält `Authorization: Negotiate <token>`

## Keycloak-Konfiguration (UI-Walkthrough)

Realm und LDAP+Kerberos-Federation werden beim ersten Start automatisch aus `keycloak/realm-export.json` importiert. Zur manuellen Erkundung:

### LDAP-Benutzer-Federation mit Kerberos-Integration

**Admin Console → Realm kerberos-demo → User Federation → ldap**

Der LDAP-Provider übernimmt beide Aufgaben:

**Verbindung:**
| Feld | Wert |
|------|------|
| Connection URL | `ldap://openldap:389` |
| Bind DN | `cn=admin,dc=example,dc=com` |
| Users DN | `ou=users,dc=example,dc=com` |
| Username LDAP attr | `uid` |

**Kerberos-Integration (nach unten scrollen):**
| Feld | Wert |
|------|------|
| Allow Kerberos Authentication | An |
| Kerberos Realm | `EXAMPLE.COM` |
| Server Principal | `HTTP/localhost@EXAMPLE.COM` |
| KeyTab | `/keytabs/keycloak.keytab` |
| Use Kerberos For Password Auth | Aus |
| Debug | An |

### SPNEGO-Browser-Flow

**Authentication → Flows → Browser**

Der `Kerberos`-Schritt muss auf **Alternative** gesetzt sein (nicht Disabled):

```
Cookie              Alternative
Kerberos            Alternative   ← aktiviert SPNEGO
Identity Provider   Alternative
Forms               Alternative
```

## Benutzerverwaltung

### Benutzer zu LDAP hinzufügen

```bash
docker compose exec kerberos-client bash

ldapadd -x -H ldap://openldap:389 \
  -D "cn=admin,dc=example,dc=com" -w adminpassword <<EOF
dn: uid=bob,ou=users,dc=example,dc=com
objectClass: inetOrgPerson
objectClass: organizationalPerson
uid: bob
cn: Bob
sn: Smith
mail: bob@example.com
userPassword: bob
EOF
```

### Kerberos-Principal hinzufügen

```bash
docker compose exec kerberos kadmin.local

# In kadmin.local:
addprinc bob                # fragt nach Passwort
listprincs                  # überprüfen
quit
```

Bob hat jetzt Einträge in beiden Systemen und kann sich per SPNEGO anmelden.

### Nur Kerberos (zum Testen der Ablehnung)

Einen Principal ohne entsprechenden LDAP-Eintrag anlegen — Keycloak lehnt die Anmeldung ab, auch wenn das Ticket gültig ist, weil der Benutzer nicht im Verzeichnis gefunden wird.

## Nützliche Befehle

```bash
# Alle Logs verfolgen
docker compose logs -f

# Nur Keycloak-Kerberos-Ausgabe
docker compose logs -f keycloak | grep -i -E "kerberos|spnego|negotiate|keytab|ldap"

# Alle Kerberos-Principals auflisten
docker compose exec kerberos kadmin.local -q "listprincs"

# LDAP-Verzeichnis durchsuchen
ldapsearch -x -H ldap://localhost:389 \
  -b "dc=example,dc=com" \
  -D "cn=admin,dc=example,dc=com" \
  -w adminpassword

# Vollständiger Reset — löscht KDC-Datenbank, LDAP-Daten und Keytabs
docker compose down -v && docker compose up --build
```

## Dateistruktur

```
.
├── docker-compose.yml         # kerberos, openldap, keycloak, kerberos-client
├── .env.example               # Vorlage für Umgebungsvariablen (nach .env kopieren)
├── krb5.conf                  # Kerberos-Konfiguration für den Keycloak-Container
├── krb5-host.conf             # Kerberos-Konfiguration für den Host / Laptop
├── kerberos/
│   ├── Dockerfile             # MIT KDC Image (debian:bookworm-slim)
│   ├── krb5.conf              # KDC-interne Konfiguration (nutzt Docker-Servicenamen)
│   ├── kdc.conf               # KDC-Daemon-Konfiguration
│   ├── kadm5.acl              # kadmind-ACL
│   └── init-kdc.sh            # DB-Initialisierung + Principal-Bootstrap beim ersten Start
├── openldap/
│   └── bootstrap.ldif         # Initiale OUs und Benutzer für OpenLDAP
└── keycloak/
    └── realm-export.json      # Realm kerberos-demo mit LDAP+Kerberos-Federation
```

## Fehlerbehebung

| Symptom | Ursache | Lösung |
|---------|---------|--------|
| `Cannot contact any KDC` | Port 88 nicht erreichbar | `docker compose ps` und `nc -zv localhost 88` prüfen |
| `Clock skew too great` | Systemuhr um mehr als 5 Minuten abgewichen | Docker neu starten / Uhr synchronisieren |
| Kein `WWW-Authenticate: Negotiate` | Kerberos-Schritt deaktiviert oder Keytab nicht geladen | Schritt auf **Alternative** setzen; Keycloak-Logs auf Keytab-Fehler prüfen |
| Browser zeigt Login-Formular trotz TGT | Browser-SPNEGO nicht konfiguriert oder Snap/Flatpak-Firefox | `about:config` konfigurieren; natives Firefox-Paket installieren |
| `KeyTab is null` in Keycloak-Logs | KDC war noch nicht healthy als Keycloak startete | `docker compose restart keycloak` |
| LDAP-Verbindungsfehler in Keycloak | OpenLDAP noch nicht bereit | `docker compose restart keycloak` nach dem openldap healthy ist |
| Benutzer authentifiziert, aber nicht gefunden | Kerberos-Principal ohne LDAP-Eintrag | LDAP-Eintrag hinzufügen (siehe Benutzerverwaltung) |
