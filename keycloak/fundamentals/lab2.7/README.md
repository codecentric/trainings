Run this command to apply all config files in the ./confg directory.

```
docker run \
    -e KEYCLOAK_URL="http://keycloak:8080/" \
    -e KEYCLOAK_USER="admin" \
    -e KEYCLOAK_PASSWORD="admin" \
    -e KEYCLOAK_AVAILABILITYCHECK_ENABLED=true \
    -e KEYCLOAK_AVAILABILITYCHECK_TIMEOUT=5s \
    -e IMPORT_FILES_LOCATIONS='/config/*' \
    --network=lab-2-7-network  \
    -v ./config:/config \
    adorsys/keycloak-config-cli:latest-24.0.5
```