# Lab Optimized Build of Keycloak

Ziel: Wir erstellen ein eigenes Keycloak Image um die Performance zu steigern.

1) Schaue dir die Dockerfile an. Was passiert hier? Warum wird hier zweimal `from` genutzt?
2) Kompiliere das Docker Image auf der Konsole: `docker build -t my-own-keycloak .`
3) Nimm an der Dockerfile folgende Änderungen vor:
    - Setze das Image auf `docker.io/library/my-own-keycloak`
    - Setze die Environment Variablen `KC_HTTP_ENABLED: true` und `KC_HOSTNAME_STRICT: false`
    - Entfernen Sie den `command` Block
4) Starten Sie die Compose File. Startet der Keycloak jetzt schneller?