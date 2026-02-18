# Lab 2.8

## DE

### Teil 1 - Config Importieren

1) Startet das Lab via `docker compose up`.
2) Schaut euch die Datei im Ordner `./config` an und überlegt, welche Struktur sie beschreibt.
3) Führt das unten stehende Kommando auf der Kommandozeile aus.
4) Prüft, ob die zuvor gesehene Struktur im `./config`-Ordner umgesetzt wurde.

### Teil 2 - Config Variablen Substituieren

1) Löscht nun eure Container und volumes und startet mit `docker compose up` eine neue leere Umgebung.
2) Modifiziert die Config Datei, indem ihr den Wert des Nachnamen durch `$(LASTNAME)` ersetzt.
3) Modifiziert das docker run Kommando der Keycloak Config CLI
    * Ergänzt die env `IMPORT_VAR_SUBSTITUTION_ENABLED=true`
    * Ergänzt die env `LASTNAME=codecentric`
4) Setzt die Config wie zuvor um und prüft, ob alles geklappt hat.

## EN

### Part 1 - Import config

1) Start the Lab via `docker compose up`.
2) Look at the file in the `./config` folder and think about the structure it describes.
3) Make sure, you are in the compose file's directory on the command line. Execute the command below on the command line. Under Windows, the line breaks and line-ending slashes may have to be removed.
4) Check whether the previously seen structure in the `./config` folder has been implemented.

### Part 2 - Substituting config variables

1) Now delete your containers and volumes and start a new empty environment with `docker compose up`.
2) Modify the config file by replacing the value of the last name with `$(LASTNAME)`.
3) Modify the docker run command of the Keycloak Config CLI
    * Add the env `IMPORT_VAR_SUBSTITUTION_ENABLED=true`.
    * Add the env `LASTNAME=codecentric`.
4) Apply the config as before and check whether everything has worked.

## Docker Compose Command

```bash
docker compose run --remove-orphans keycloak-config
```