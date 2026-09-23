# Compose Test

## DE

Mit diesem Setup könnt ihr vorab testen, ob eure lokale Container-Umgebung einsatzbereit für die Schulung ist.

### Voraussetzungen
Bevor ihr startet, muss entweder Docker Desktop oder Podman Desktop auf eurem Rechner installiert und gestartet sein:
* **Docker Desktop:** https://www.docker.com/products/docker-desktop/ (bringt `docker compose` standardmäßig mit)
* **Podman Desktop:** https://podman-desktop.io/ (stellt sicher, dass die Compose-Unterstützung bzw. `podman-compose` aktiviert/installiert ist)

### Test ausführen
1) Öffnet ein Terminal und wechselt in dieses Verzeichnis (`keycloak/fundamentals/composetest`).
2) Startet den Keycloak-Container im Hintergrund:
    * **Docker:** `docker compose up -d`
    * **Podman:** `podman compose up -d`
3) Öffnet euren Browser und ruft folgende Adresse auf:
    * http://localhost:8080
    * Wenn die Keycloak-Startseite erreichbar ist, funktioniert euer Setup einwandfrei.
4) Wenn der Test erfolgreich war, könnt ihr den Container wieder beenden und aufräumen:
    * **Docker:** `docker compose down`
    * **Podman:** `podman compose down`

---

## EN

Use this setup to verify that your local container environment is ready for the training session.

### Prerequisites
Before running the test, please make sure either Docker Desktop or Podman Desktop is installed and running on your machine:
* **Docker Desktop:** https://www.docker.com/products/docker-desktop/ (comes with `docker compose` out of the box)
* **Podman Desktop:** https://podman-desktop.io/ (ensure Compose support or `podman-compose` is enabled/installed)

### Running the Test
1) Open a terminal and navigate to this directory (`keycloak/composetest`).
2) Start the Keycloak container in detached mode:
    * **Docker:** `docker compose up -d`
    * **Podman:** `podman compose up -d`
3) Open your browser and go to:
    * http://localhost:8080
    * If the Keycloak welcome page opens, your setup is working as expected.
4) Once verified, stop and clean up the container:
    * **Docker:** `docker compose down`
    * **Podman:** `podman compose down`
