# Lab 2.2

## DE

1) Bitte öffnet die in diesem Verzeichnis liegende Datei `docker-compose.yaml`. Sie ist der aus der vorherigen Lab sehr ähnlich.
2) Aktuell nutzt Keycloak in dieser Konfiguration eine H2 Datenbank, die für eine Produktionsumgebung nicht empfohlen wird. Sie sollte z. B. auf eine PostgreSQL Datenbank umgestellt werden, indem ihr die .yaml-Datei anpasst. Schaut euch hierzu die Containerdokumentation an: https://www.keycloak.org/server/containers
    * Interessant für euch sind insbesondere die Environmentvariablen `KC_DB`, `KC_DB_URL`, `KC_DB_USERNAME` und `KC_DB_PASSWORD` die ihr eurem Keycloak-Container hinzufügen solltet.
    * Die `KC_DB` URL sieht etwa so aus: `jdbc:postgresql://<DB_HOST>/<DB_NAME>`
    * Fügt der .yaml-Datei auch einen PostgreSQL Container hinzu (s. unten).
3) Wechselt auf der Kommandozeile in diesen Ordner und führt `docker compose up` aus und prüft, ob eure Konfiguration erfolgreich war.
4) Schaut die SPI `connectionsJpa` im Provider Info Tab an nach dem Login.

Wie ein PostgreSQL Container aussehen könnte, ist unten beschrieben.

## EN

1) Please open the file `docker-compose.yaml` located in this directory. It is very similar to the one from the previous lab.
2) Keycloak currently uses an H2 database in this configuration, which is not recommended for a production environment. It should be switched to a PostgreSQL database by adapting the .yaml file. Take a look at the container documentation: https://www.keycloak.org/server/containers
   * Of particular interest to you are the environment variables `KC_DB`, `KC_DB_URL`, `KC_DB_USERNAME` and `KC_DB_PASSWORD` which you should add to your Keycloak container.
   * The `KC_DB` URL looks something like this: `jdbc:postgresql://<DB_HOST>/<DB_NAME>`
   * Also add a PostgreSQL container to the .yaml file (see below).
3) Change to this folder on the command line and execute `docker compose up` and check if your configuration was successful.
4) Check the SPI `connectionsJpa` in the Provider Info Tab after the login.

How a PostgreSQL container could look like is described below.

## PostgreSQL Contrainer
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