# Lab 2.7 – Themes

## DE

### Ziel

In diesem Lab wird ein eigenes Login-Theme erstellt und eingebunden. Du lernst, wie Themes in Keycloak strukturiert sind (Ordnerstruktur, `theme.properties`), wie ein Theme über die Realm-Settings aktiviert und über ein Volume in den Container eingebunden wird — und wie kleine Anpassungen wie eine Farbänderung das Login-Formular verändern.

1) Prüft die `docker-compose.yaml` auf Änderungen und versucht zu verstehen, was diese machen.
2) Startet das Lab via `docker compose up`.
3) Legt einen Realm an und setzt in den Realm Settings das Login-Theme auf `training-theme`.
4) Schaut euch den `themes`-Ordner an und versteht seine Struktur sowie die `theme.properties`-Datei.
5) Nehmt eine kleine Änderung (z. B. eine Farbe im CSS File) vor und prüft die Auswirkungen.

## EN

### Goal

In this lab, a custom login theme is created and integrated. You will learn how themes are structured in Keycloak (folder structure, `theme.properties`), how a theme is activated via the realm settings and mounted into the container via a volume — and how small adjustments such as a color change alter the login form.

1) Check the `docker-compose.yaml` for changes and try to understand what they do.
2) Start the lab via `docker compose up`.
3) Create a realm and set the login theme to `training-theme` in the realm settings.
4) Have a look at the `themes` folder and understand its structure as well as the `theme.properties` file.
5) Make a small change (e.g. a color in the CSS file) and check the effects.