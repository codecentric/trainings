# Lab 3.2

## DE

1) Startet das Lab via `docker compose up`.
2) Realm `labrealm` und einen Testbenutzer anlegen
3) Lege einen Client `spa` an (ohne Client Auth) und erlaube `http://localhost:8081/* ` als Redirect URL
4) Rufe die SPA im Browser auf http://localhost:8081 und prüfe den Login mit deinem Testbenutzer auf Funktion
5) Nutze die Developer Tools / Cookies / SPA Code um den Login- und Logout-Ablauf nachzuvollziehen
6) Logge dich ein der SPA ein. Rufe dann die Account Console mit dem gleichen Benutzer auf und logge dich dort aus. Du kannst beobachten, dass du auch in der SPA ausgeloggt wirst, da Keycloak Single-Sign-Out unterstützt.

## EN

1) Start the lab via `docker compose up`.
2) Create realm `labrealm` and a test user
3) Create a client `spa` (without client auth) and allow `http://localhost:8081/* ` as redirect URL
4) Open the SPA in the browser http://localhost:8081 and check the login with your test user for functionality
5) Use the Developer Tools / Cookies / SPA Code to track the login and logout process
6) Log in to the SPA. Then call up the Account Console with the same user and log out there. You can see that you are also logged out in the SPA, as Keycloak supports single sign-out.