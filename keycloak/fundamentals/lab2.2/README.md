# Lab 2.2

1) Bitte öffnet die in diesem Verzeichnis liegende Datei `docker-compose.yaml`. Sie ist der aus der vorherigen Lab sehr ähnlich.
2) Aktuell nutzt Keycloak in dieser Konfiguration eine H2 Datenbank, die für eine Produktionsumgebung nicht empfohlen wird. Sie sollte z. B. auf eine PostgreSQL Datenbank umgestellt werden, indem ihr die .yaml-Datei anpasst. Schaut euch hierzu die Containerdokumentation an: https://www.keycloak.org/server/containers
    * Interessant für euch sind insbesondere die Environmentvariablen `KC_DB`, `KC_DB_URL`, `KC_DB_USERNAME` und `KC_DB_PASSWORD` die ihr eurem Keycloak-Container hinzufügen solltet.
    * Die `KC_DB` URL sieht etwa so aus: `jdbc:postgresql://<DB_HOST>/<DB_NAME>`
    * Fügt der .yaml-Datei auch einen PostgreSQL Container hinzu (s. unten).
3) Wechselt auf der Kommandozeile in diesen Ordner und führt `docker compose up` aus und prüft, ob eure Konfiguration erfolgreich war.

Ein PostgreSQL Container könnte z. B. so aussehen:

```yaml
  postgres:
    image: postgres
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: postgres_user
      POSTGRES_PASSWORD: postgres_pass
    ports:
        - 5432:5432
    networks:
      - backend
    volumes:
        - postgres-data:/var/lib/postgresql/data
```