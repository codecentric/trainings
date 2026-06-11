# Lab Organizations

## DE

Ziel: Ihr lernt, wie ihr in Keycloak Organizations nutzt, um Benutzer anhand ihrer E-Mail-Domain automatisch an den richtigen Identity Provider weiterzuleiten (Multi-Tenancy).

Die beiden Kunden-Realms (`customer_a` und `customer_b`) werden beim Start automatisch importiert. Sie repräsentieren externe Identity Provider und sind bereits vollständig vorkonfiguriert:

| Realm | Benutzer | Passwort | Client | Client Secret |
|-------|----------|----------|--------|---------------|
| `customer_a` | `stefan@customer-a.test` | `customer-a` | `multi` | `customer-a-secret` |
| `customer_b` | `jens@customer-b.test` | `customer-b` | `multi` | `customer-b-secret` |

## Erster Teil: Multi-Realm und Identity Provider einrichten

1) Startet das Lab via `docker compose up`.
2) Öffnet die Admin Console unter http://localhost:8080 und meldet euch mit `admin`/`admin` an.
3) Lege den Realm **"multi"** an.
4) Aktiviere im "multi"-Realm unter **Realm settings → General** das Feld **"Organizations"**.
5) Aktiviere unter **Realm settings → Login** das Feld **"Email as username"**.
6) Konfiguriere die beiden Kunden-Realms als **"Keycloak OpenID Connect"**-Identity-Provider im "multi"-Realm.  
   Die Discovery-Endpoints lauten:
   - `http://localhost:8080/realms/customer_a/.well-known/openid-configuration`
   - `http://localhost:8080/realms/customer_b/.well-known/openid-configuration`

   Nutze als Client ID `multi` und die zugehörigen Client Secrets aus der Tabelle oben.

## Zweiter Teil: Organizations einrichten

1) Erstelle im "multi"-Realm zwei Organizations:
   - Name `customer_a`, Domain `customer-a.test` → verknüpft mit dem Identity Provider für `customer_a`
   - Name `customer_b`, Domain `customer-b.test` → verknüpft mit dem Identity Provider für `customer_b`
2) Wähle bei jedem Identity Provider in der Organization-Konfiguration die Domain aus und aktiviere die Optionen **"Hide on login page"** sowie **"Redirect when email domain matches"**.

## Dritter Teil: Login testen

1) Öffne die Account Console des "multi"-Realms: http://localhost:8080/realms/multi/account/
2) Gib die E-Mail-Adresse eines der beiden Kundenbenutzer ein. Du siehst, wie eine automatische Weiterleitung zum richtigen Identity Provider passiert — erkennbar daran, dass der Realm-Name in der URL erscheint. Gib dort das Passwort ein.
3) Nach erfolgreichem Login wirst du zurück in den "multi"-Realm weitergeleitet.
4) Der eingeloggte Benutzer ist nun auch im "multi"-Realm in der Admin Console sichtbar.

Was ist passiert? Keycloak hat über die Domain der E-Mail-Adresse die zugehörige Organization — und damit den richtigen Identity Provider — ermittelt und die Weiterleitung automatisch vorgenommen.

---

## EN

Goal: You will learn how to use Keycloak Organizations to automatically route users to the correct identity provider based on their email domain (multi-tenancy).

The two customer realms (`customer_a` and `customer_b`) are automatically imported on startup. They represent external identity providers and are fully pre-configured:

| Realm | User | Password | Client | Client Secret |
|-------|------|----------|--------|---------------|
| `customer_a` | `stefan@customer-a.test` | `customer-a` | `multi` | `customer-a-secret` |
| `customer_b` | `jens@customer-b.test` | `customer-b` | `multi` | `customer-b-secret` |

## Part One: Set up the multi realm and identity providers

1) Start the lab via `docker compose up`.
2) Open the Admin Console at http://localhost:8080 and log in with `admin`/`admin`.
3) Create the realm **"multi"**.
4) Enable **"Organizations"** in the "multi" realm under **Realm settings → General**.
5) Enable **"Email as username"** under **Realm settings → Login**.
6) Configure the two customer realms as **"Keycloak OpenID Connect"** identity providers in the "multi" realm.  
   The discovery endpoints are:
   - `http://localhost:8080/realms/customer_a/.well-known/openid-configuration`
   - `http://localhost:8080/realms/customer_b/.well-known/openid-configuration`

   Use client ID `multi` and the corresponding client secrets from the table above.

## Part Two: Set up Organizations

1) Create two organizations in the "multi" realm:
   - Name `customer_a`, domain `customer-a.test` → linked to the `customer_a` identity provider
   - Name `customer_b`, domain `customer-b.test` → linked to the `customer_b` identity provider
2) For each identity provider in the organization config, select the domain and enable both **"Hide on login page"** and **"Redirect when email domain matches"**.

## Part Three: Test the login

1) Open the Account Console of the "multi" realm: http://localhost:8080/realms/multi/account/
2) Enter the email address of one of the two customer users. You will see an automatic redirect to the correct identity provider — recognizable by the realm name appearing in the URL. Enter the password there.
3) After a successful login you are redirected back to the "multi" realm.
4) The logged-in user is now also visible in the "multi" realm's user list in the Admin Console.

What happened? Keycloak used the email domain to determine the matching organization — and therefore the correct identity provider — and performed the redirect automatically.
