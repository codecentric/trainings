# Lab 2.4

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