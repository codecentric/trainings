# Kerberos + LDAP + Keycloak Playground

A self-contained Docker Compose setup for learning and experimenting with
MIT Kerberos, OpenLDAP, and Keycloak's SPNEGO user federation.

Everything runs locally — no external services, no DNS configuration needed.

## What You Get

- **MIT Kerberos KDC** — issues tickets for realm `EXAMPLE.COM`
- **OpenLDAP** — user directory; only users that exist here can authenticate via Kerberos
- **Keycloak** — LDAP user federation with built-in Kerberos/SPNEGO support
- **kerberos-client** — a Debian shell container for testing `kinit` and `ldapsearch`

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Docker + Docker Compose v2 | `docker compose version` to verify |
| Port 88 free on host | KDC is exposed on localhost:88 |
| Port 389 free on host | LDAP is exposed on localhost:389 |
| Port 8080 free on host | Keycloak Admin UI |

**For host-based `kinit` (optional — you can also use the `kerberos-client` container):**

| OS | Install |
|----|---------|
| Debian/Ubuntu | `sudo apt install krb5-user ldap-utils` |
| macOS | Kerberos built-in; `brew install openldap` for `ldapsearch` |
| Windows | MIT Kerberos for Windows or WSL |

**For browser SPNEGO:**

- Firefox must be installed as a **native package** (deb, rpm, Homebrew) — not via Snap or Flatpak, which sandbox the browser away from system GSSAPI libraries
- Chrome/Chromium works with a policy file (see [Browser SPNEGO Setup](#browser-spnego-setup))

## The Core Idea

Kerberos proves *who you are*. LDAP defines *who is allowed in*. Keycloak bridges both.

```
Kerberos ticket valid ✓  +  user exists in LDAP ✓  →  authenticated
Kerberos ticket valid ✓  +  user NOT in LDAP    ✗  →  rejected
```

This prevents rogue Kerberos principals (users that exist in the KDC but were
never provisioned in the directory) from gaining access.

## How SPNEGO Works

```
1. kinit
   You → KDC:       "I am alice, give me a TGT"
   KDC → You:       TGT (encrypted, cached locally at /tmp/krb5cc_<uid>)

2. Browser navigates to app
   App → Keycloak:  redirect for login

3. SPNEGO negotiation
   Keycloak → Browser:   WWW-Authenticate: Negotiate
   Browser  → KDC:       "Give me a service ticket for HTTP/localhost"
   Browser  → Keycloak:  Authorization: Negotiate <ticket>

4. Keycloak validates ticket + checks LDAP
   → Decrypts ticket using keytab
   → Looks up alice in LDAP (ou=users,dc=example,dc=com)
   → Found: creates/updates Keycloak user, issues OIDC session
   → Not found: authentication rejected
```

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  Docker Compose (localhost)                                  │
│                                                              │
│  ┌──────────────┐  keytab (shared volume)                   │
│  │  kerberos    │ ─────────────────────────────────────┐    │
│  │  MIT KDC     │                                      │    │
│  │  port 88     │                                      ▼    │
│  └──────────────┘                         ┌────────────────┐ │
│                                           │   keycloak     │ │
│  ┌──────────────┐  ldap://openldap:389   │   port 8080    │ │
│  │  openldap    │ ◄─────────────────────  │   LDAP fed.    │ │
│  │  port 389    │                         │   + Kerberos   │ │
│  └──────────────┘                         └────────────────┘ │
│                                                              │
│  ┌──────────────┐                                            │
│  │ krb-client   │  kinit / ldapsearch (test shell)          │
│  └──────────────┘                                            │
└──────────────────────────────────────────────────────────────┘
        ▲  port 88                    ▲  port 8080
        │  port 389                   │
        └──────────── Host ───────────┘
```

## Quick Start

```bash
cp .env.example .env
docker compose up --build
```

Wait for all three services to be healthy (~60–90 s on first boot):
```bash
docker compose ps
```

| Service | URL / port | Credentials |
|---------|-----------|-------------|
| Keycloak Admin | http://localhost:8080 | admin / admin |
| KDC | localhost:88 | — |
| kadmind | localhost:749 | admin/admin@EXAMPLE.COM / adminpassword |
| LDAP | localhost:389 | cn=admin,dc=example,dc=com / adminpassword |

## Users and Principals

### LDAP users (`ou=users,dc=example,dc=com`)

| uid | Password | Notes |
|-----|----------|-------|
| `alice` | `userpassword` | Synced into Keycloak on first login |

### Kerberos principals (`EXAMPLE.COM`)

| Principal | Password | Purpose |
|-----------|----------|---------|
| `admin/admin@EXAMPLE.COM` | `adminpassword` | KDC admin |
| `alice@EXAMPLE.COM` | `userpassword` | Test user |
| `HTTP/localhost@EXAMPLE.COM` | (random key) | Keycloak SPNEGO service |

Alice exists in **both** LDAP and Kerberos, so she can authenticate via SPNEGO.
Add a user to Kerberos but not LDAP (or vice versa) to observe the access control.

## Testing Kerberos Authentication

### Option A — inside Docker (no host setup needed)

```bash
docker compose exec kerberos-client bash

# Test Kerberos
kinit alice@EXAMPLE.COM     # password: userpassword
klist                        # confirm TGT

# Test LDAP
ldapsearch -x -H ldap://openldap:389 \
  -b "ou=users,dc=example,dc=com" \
  -D "cn=admin,dc=example,dc=com" \
  -w adminpassword \
  "(uid=alice)"
```

### Option B — from your host machine

```bash
# Debian/Ubuntu
sudo apt install -y krb5-user ldap-utils

# macOS (Kerberos built-in, install ldap-utils via brew)
brew install openldap

sudo cp krb5-host.conf /etc/krb5.conf
kinit alice@EXAMPLE.COM     # password: userpassword
klist

ldapsearch -x -H ldap://localhost:389 \
  -b "ou=users,dc=example,dc=com" \
  -D "cn=admin,dc=example,dc=com" \
  -w adminpassword \
  "(uid=alice)"
```

## Browser SPNEGO Setup

> **Note:** Firefox must be installed as a native package (deb/rpm/brew), not via
> Snap or Flatpak — those run in a sandbox without access to the system GSSAPI
> libraries and will silently ignore the Negotiate challenge.

**Firefox** — navigate to `about:config`:
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

Restart the browser, then:

1. `kinit alice@EXAMPLE.COM`
2. Open http://localhost:8080/realms/kerberos-demo/account
3. Alice is logged in without a password prompt

Verify in DevTools → Network:
- Keycloak redirect response has `WWW-Authenticate: Negotiate`
- Following request has `Authorization: Negotiate <token>`

## Keycloak Configuration (UI Walkthrough)

The realm and LDAP+Kerberos federation are imported automatically from
`keycloak/realm-export.json` on first boot. To explore the configuration:

### LDAP User Federation with Kerberos Integration

**Admin Console → kerberos-demo realm → User Federation → ldap**

The LDAP provider handles both concerns:

**Connection:**
| Field | Value |
|-------|-------|
| Connection URL | `ldap://openldap:389` |
| Bind DN | `cn=admin,dc=example,dc=com` |
| Users DN | `ou=users,dc=example,dc=com` |
| Username LDAP attr | `uid` |

**Kerberos Integration (scroll down):**
| Field | Value |
|-------|-------|
| Allow Kerberos Authentication | On |
| Kerberos Realm | `EXAMPLE.COM` |
| Server Principal | `HTTP/localhost@EXAMPLE.COM` |
| KeyTab | `/keytabs/keycloak.keytab` |
| Use Kerberos For Password Auth | Off |
| Debug | On |

### SPNEGO Browser Flow

**Authentication → Flows → Browser**

The `Kerberos` step must be **Alternative** (not Disabled):

```
Cookie              Alternative
Kerberos            Alternative   ← enables SPNEGO
Identity Provider   Alternative
Forms               Alternative
```

## Managing Users

### Add a user to LDAP

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
userPassword: bobpassword
EOF
```

### Add a Kerberos principal

```bash
docker compose exec kerberos kadmin.local

# Inside kadmin.local:
addprinc bob                # prompts for password
listprincs                  # verify
quit
```

Bob now has both LDAP and Kerberos entries — he can authenticate via SPNEGO.

### Add to Kerberos only (to test rejection)

Add a principal without a corresponding LDAP entry — Keycloak will reject it
even with a valid ticket, because the user cannot be found in the directory.

## Useful Commands

```bash
# Watch all logs
docker compose logs -f

# Watch Keycloak Kerberos output specifically
docker compose logs -f keycloak | grep -i -E "kerberos|spnego|negotiate|keytab|ldap"

# List all Kerberos principals
docker compose exec kerberos kadmin.local -q "listprincs"

# Browse LDAP tree
ldapsearch -x -H ldap://localhost:389 \
  -b "dc=example,dc=com" \
  -D "cn=admin,dc=example,dc=com" \
  -w adminpassword

# Full reset — wipes KDC database, LDAP data and keytabs
docker compose down -v && docker compose up --build
```

## File Layout

```
.
├── docker-compose.yml         # kerberos, openldap, keycloak, kerberos-client
├── .env.example               # environment variable template (copy to .env)
├── krb5.conf                  # Kerberos config mounted into Keycloak container
├── krb5-host.conf             # Kerberos config for your host / laptop
├── kerberos/
│   ├── Dockerfile             # MIT KDC image (debian:bookworm-slim)
│   ├── krb5.conf              # KDC-internal config (uses Docker service name)
│   ├── kdc.conf               # KDC daemon config
│   ├── kadm5.acl              # kadmind ACL
│   └── init-kdc.sh            # DB init + principal bootstrap on first boot
└── keycloak/
    └── realm-export.json      # kerberos-demo realm with LDAP+Kerberos federation
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Cannot contact any KDC` | Port 88 not reachable | Check `docker compose ps` and `nc -zv localhost 88` |
| `Clock skew too great` | Host clock drifted >5 min | Restart Docker / sync host clock |
| No `WWW-Authenticate: Negotiate` | Kerberos step disabled or keytab not loaded | Set step to **Alternative**; check Keycloak logs for keytab errors |
| Browser shows login form despite TGT | Browser SPNEGO not configured or Snap/Flatpak Firefox | Configure `about:config`; install native Firefox package |
| `KeyTab is null` in Keycloak logs | KDC not yet healthy when Keycloak started | `docker compose restart keycloak` |
| LDAP connection refused in Keycloak | OpenLDAP not yet ready | `docker compose restart keycloak` after `openldap` is healthy |
| User authenticated but not found | User has Kerberos principal but no LDAP entry | Add LDAP entry (see Managing Users above) |
