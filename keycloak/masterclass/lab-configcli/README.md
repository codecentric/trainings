# Lab Config CLI

## DE

Ziel: Ihr lernt, wie ihr mit dem keycloak-config-cli Keycloak-Konfigurationen deklarativ importiert und wie ihr dabei Variablen-Substitution einsetzt, um Konfigurationen flexibel zu gestalten.

### Teil 1 - Config Importieren

1) Startet das Lab via `docker compose up`.
2) Schaut euch die Datei im Ordner `./config` an und überlegt, welche Struktur sie beschreibt.
3) Führt das Kommando `docker compose run --remove-orphans keycloak-config` auf der Kommandozeile aus.
4) Prüft, ob die zuvor gesehene Struktur im `./config`-Ordner umgesetzt wurde.

### Teil 2 - Config Variablen Substituieren

1) Löscht nun eure Container und volumes und startet mit `docker compose up` eine neue leere Umgebung.
2) Modifiziert die Config Datei, indem ihr den Wert des Nachnamen durch `$(LASTNAME)` ersetzt.
3) Fügt in der compose file für die Config CLI folgende ENV-Variablen hinzu:
   * Ergänzt die env `IMPORT_VAR_SUBSTITUTION_ENABLED: true`
   * Ergänzt die env `LASTNAME: "codecentric"`
4) Setzt die Config wie zuvor um und prüft, ob alles geklappt hat.

## EN

Goal: You will learn how to declaratively import Keycloak configurations using keycloak-config-cli and how to use variable substitution to make configurations flexible.

### Part 1 - Import config

1) Start the Lab via `docker compose up`.
2) Look at the file in the `./config` folder and think about the structure it describes.
3) Make sure, you are in the compose file's directory on the command line. Execute the command `docker compose run --remove-orphans keycloak-config` on the command line. Under Windows, the line breaks and line-ending slashes may have to be removed.
4) Check whether the previously seen structure in the `./config` folder has been implemented.

### Part 2 - Substituting config variables

1) Now delete your containers and volumes and start a new empty environment with `docker compose up`.
2) Modify the config file by replacing the value of the last name with `$(LASTNAME)`.
3) Please add the following ENV-Variables to the Config CLI block in the compose file: 
   * Add the env `IMPORT_VAR_SUBSTITUTION_ENABLED: true`.
   * Add the env `LASTNAME: "codecentric"`.
4) Apply the config as before and check whether everything has worked.
