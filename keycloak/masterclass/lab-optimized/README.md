# Lab Optimized Build of Keycloak

## DE

Ziel: Wir erstellen ein eigenes Keycloak Image um die Performance zu steigern.

1) Schaue dir die Dockerfile an. Was passiert hier? Warum wird hier zweimal `from` genutzt?
2) Kompiliere das Docker Image auf der Konsole: `docker build -t my-own-keycloak .`
3) Nimm an der Dockerfile folgende Änderungen vor:
    - Setze das Image auf `docker.io/library/my-own-keycloak`
    - Setze die Environment Variablen `KC_HTTP_ENABLED: true` und `KC_HOSTNAME_STRICT: false`
    - Entfernen Sie den `command` Block
4) Starten Sie die Compose File. Startet der Keycloak jetzt schneller?
Bonus) Schaue in der Dokumentation von Keycloak nach, warum die beiden obigen Umgebungsvariablen gesetzt werden müssen

---

## EN

Goal: We will create our own Keycloak image to improve performance.

1) Look at the Dockerfile. What happens here? Why is `from` used twice?
2) Compile the Docker image on the console: `docker build -t my-own-keycloak .`
3) Make the following changes to the Dockerfile:
    - Set the image to `docker.io/library/my-own-keycloak`
    - Set the environment variables `KC_HTTP_ENABLED: true` and `KC_HOSTNAME_STRICT: false`
    - Remove the `command` block
4) Start the Compose file. Does Keycloak start faster now?
Bonus) Check the Keycloak documentation to find out why the two environment variables above need to be set
