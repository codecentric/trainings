# Lab 3.2

1) Startet das Lab via `docker compose up`.
2) Realm `labrealm` und einen Testbenutzer anlegen
3) Lege einen Client `spa` an (ohne Client Auth) imd erlaube `http://localhost:8081/* ` als Redirect URL
4) Rufe die SPA im Browser auf http://localhost:8081 und prüfe den Login mit deinem Testbenutzer auf Funktion
5) Nutze die Developer Tools / Cookies / SPA Code um den Login- und Logout-Ablauf nachzuvollziehen
6) Logge dich ein der SPA ein. Rufe dann die Account Console mit dem gleichen Benutzer auf und logge dich dort aus. Du kannst beobachten, dass du auch in der SPA ausgeloggt wirst, da Keycloak Single-Sign-Out unterstützt.
