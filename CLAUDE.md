# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a codecentric training materials repository containing Docker Compose-based lab exercises for **Keycloak** (IAM) and **Kafka Security** courses. Materials are instructor-led, not for general public use. Documentation is bilingual (German/English).

## Repository Structure

```
keycloak/
├── fundamentals/       # Core Keycloak labs (lab2.1–lab2.8, lab3.1–lab3.2)
├── kafka/              # Kafka security with Keycloak (lab2.1–lab2.3)
└── masterclass/        # Template placeholder for future labs
```

Each lab is self-contained with its own `docker-compose.yml` and `README.md`.

## Running Labs

```bash
# Start a lab environment
docker compose -f keycloak/fundamentals/lab2.1/docker-compose.yml up

# Or navigate into the lab directory first
cd keycloak/fundamentals/lab2.1 && docker compose up

# Tear down (including volumes)
docker compose down -v
```

Keycloak admin UI: http://localhost:8080 (credentials: `admin`/`admin`)

Lab-specific endpoints:
- Lab 3.1 (OAuth2 Proxy): http://localhost:4180/
- Lab 3.2 (SPA): http://localhost:8081/
- Kafka labs (Kafka UI): http://localhost:8082/

## Key Versions and Images

- **Keycloak (fundamentals):** `quay.io/keycloak/keycloak:26.3.3`
- **Keycloak (kafka):** `quay.io/keycloak/keycloak:25.0.1`
- **Kafka/Zookeeper:** `confluentinc/cp-kafka:7.6.1` / `confluentinc/cp-zookeeper:7.6.1`
- **OpenLDAP:** `bitnamilegacy/openldap:2`
- **OAuth2 Proxy:** `quay.io/oauth2-proxy/oauth2-proxy:v7.6.0`

## Lab Progression

Labs build on each other in increasing complexity:
- **2.1–2.2:** Basic Keycloak setup, PostgreSQL database
- **2.3:** LDAP user federation
- **2.4–2.5:** Token handling, impersonation, exchange
- **2.6:** Custom user attributes, conditional authentication
- **2.7:** Custom login themes (theme files in `lab2.7/themes/`)
- **2.8:** Configuration import via keycloak-config-cli (`lab2.8/config/`)
- **3.1:** OAuth2 Proxy / OIDC integration
- **3.2:** SPA with Keycloak.js (`lab3.2/html/`)

## Conventions

- Lab directories follow `labX.Y/` naming (chapter.section)
- Standard realm name: `labrealm` (Kafka labs use `kafka`)
- Standard test users: `admin`, `labuser`, `user01`
- Standard clients: `labclient`, `spa`, `proxy`
- All labs run Keycloak in `start-dev` mode
- When updating Keycloak versions, update all fundamentals labs together and kafka labs together
