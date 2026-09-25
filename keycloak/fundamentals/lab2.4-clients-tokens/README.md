# Lab 2.4 – Clients & Tokens

## DE

### Ziel

In diesem Lab werden die zentralen Konzepte von OAuth2/OIDC in der Praxis kennenengelernt: Realm, Client und User werden angelegt und über den Direct Access Grant (Resource Owner Password Credentials) per curl ein Token abgerufen. Du lernst, wie ein Token-Request aussieht, was ein Access Token (JWT) enthält und wie du es mit jwt.io analysierst — die Grundlage für alle weiteren Labs.

1) Startet das Lab via `docker compose up`.
2) Legt einen neuen Realm mit dem Namen `labrealm` an.
3) Legt einen neuen Client mit dem Namen `labclient` an. Die Einstellungen können auf Default bleiben. Achtet darauf, den Direct Access Grant zu aktivieren.
4) Legt einen neuen User `labuser` an. Achtet darauf den Benutzer vollständig zu konfigurieren. Dies wird auch für alle weiteren Benutzer, die ihr in Labs anlegen werdet, notwendig sein:
   * Vor- und Nachname
   * Mail
   * Passwort (nicht temporary)
   * Keine Required Actions
   * Email Verified einschalten
5) Nutzt Curl auf im Terminal/Powershell um einen Token abzurufen. Ein Beispiel findet ihr hier: https://www.keycloak.org/docs/24.0.5/securing_apps/#example-using-curl. Beachtet: Wenn ihr einen Client ohne Client Authentication angelegt habt, dann hat dieser kein Client Secret und dieser Parameter kann entfallen.
6) Nutzt den Debugger auf der Startseite von https://jwt.io, um das erhaltene Token zu analysieren.

### Hinweis für Windows Nutzer

cURL unter Windows ist nicht gleich cURL unter macOS oder Linux und funktioniert ganz anders. Unter Windows empfehlen wir Invoke-WebRequest unter Powershell. Unten ist ein Beispiel.

## EN

### Goal

In this lab, you will get to know the central concepts of OAuth2/OIDC in practice: realm, client and user are created and a token is retrieved via curl using the Direct Access Grant (Resource Owner Password Credentials). You will learn what a token request looks like, what an access token (JWT) contains and how to analyze it with jwt.io — the foundation for all subsequent labs.

1) Starts the lab via `docker compose up`.
2) Create a new realm with the name `labrealm`.
3) Create a new client with the name `labclient`. The settings can remain at default. Make sure to activate the Direct Access Grant.
4) Create a new user `labuser`. Make sure that the user is fully configured. This will also be necessary for all other users that you will create in Labs:
   * First and last name
   * Mail
   * Password (not temporary)
   * No Required Actions
   * Enable Email Verified
5) Use Curl on in the terminal/powershell to retrieve a token. You can find an example here: https://www.keycloak.org/docs/24.0.5/securing_apps/#example-using-curl. Please note: If you have created a client without client authentication, it does not have a client secret and this parameter can be omitted.
6) Use the debugger on the start page of https://jwt.io to analyze the received token.

### Note for Windows users

cURL under Windows is not the same as cURL under macOS or Linux and works completely differently. Under Windows we recommend Invoke-WebRequest under Powershell. Below is an example.

## Invoke-WebRequest

```
$response = Invoke-WebRequest -Uri "http://localhost:8080/my/url" `
   -Method POST `
   -Body @{
      param1 = "value"
      param1 = "value"
      ... more parameteres
   } `
   -ContentType "application/x-www-form-urlencoded"
$response.Content
```