# Demo: Invitation Link via Keycloak Action Email

This demo shows how to send an action email to a user via the Keycloak Admin API using a service account to act as an invitation link.

## Setup

```bash
docker compose up
```

- **Keycloak:** http://localhost:8080 (admin / admin)
- **MailHog:** http://localhost:8025

## What's configured

- Realm `lab-realm` with SMTP pointing to MailHog
- User `invited-user@example.com` — email only, no password, has `UPDATE_PASSWORD` required action
- Client `admin-api-client` with service account granted `manage-users` on `realm-management`

## Sending an action email via Admin API

### 1. Get an access token for the service account

```bash
TOKEN=$(curl -s -X POST http://localhost:8080/realms/lab-realm/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=admin-api-client" \
  -d "client_secret=admin-api-secret" \
  | jq -r '.access_token')
```

### 2. Look up the user ID

```bash
USER_ID=$(curl -s "http://localhost:8080/admin/realms/lab-realm/users?email=invited-user@example.com" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -r '.[0].id')
```

### 3. Send the action email

```bash
curl -s -X PUT "http://localhost:8080/admin/realms/lab-realm/users/$USER_ID/execute-actions-email" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '["UPDATE_PASSWORD", "UPDATE_PROFILE"]'
```

Check MailHog at http://localhost:8025 — the password-reset email will appear there.

## Teardown

```bash
docker compose down -v
```
