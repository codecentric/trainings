# Lab 2.7

## DE

1) Startet das Lab via `docker compose up`.
2) Schaut euch die Datei im Ordner `./config` an und überlegt, welche Struktur sie beschreibt.
3) Führt das unten stehende Kommando auf der Kommandozeile aus. Unter Windows müssen mglw. die Zeilenumbrüche und die zeilenabschließenden Slashes entfernt werden.
4) Prüft, ob die zuvor gesehene Struktur im `./config`-Ordner umgesetzt wurde.

## EN

1) Start the Lab via `docker compose up`.
2) Look at the file in the `./config` folder and think about the structure it describes.
3) Execute the command below on the command line. Under Windows, the line breaks and line-ending slashes may have to be removed.
4) Check whether the previously seen structure in the `./config` folder has been implemented.

## Docker Command

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