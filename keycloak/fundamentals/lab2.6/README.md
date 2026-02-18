# Lab 2.6

## DE

1) Startet das Lab via `docker compose up`.
2) Legt einen neuen Realm und einen Benutzer im Realm an.
3) Fügt in den Realm settings dem User profile ein neues Attribut mit dem Namen `farbe` hinzu. Nutzt die Permissions im Erstellungsdialog um das Attribut durch User & Admin einsehbar und editierbar zu machen.
4) Öffnet unter User euren zuvor erstellten Benutzer und setzt dort seine Lieblings-`farbe` auf einen Wert, z. B. `rot`.
5) Dupliziert unter Authentication über das Drei-Punkte-Menü den Browser Flow und passt ihn so an, dass Benutzer mit `farbe==rot` auf `Access Denied` kommen.
   * Fügt dazu unterhalb des Username Passwort Forms via + -> Add Sub Flow einen Schritt mit dem Namen `farbe-step` hinzu. Ihr könnt es via Drag&Drop direkt unter dem Username Passwort Form platzieren. Er sollte als conditional markiert werden.
   * Fügt `farbe-step` eine Condition `user attribute` hinzu und konfiguriert via Zahnrad-Symbol den Attribute name auf `farbe` und den Expected attribute value auf `rot`.
   * Fügt `farbe-step` eine Execution `Deny Access` hinzu.
   * Setzt die Condition und eurem Deny Access Step als Required.
6) Über 'Bind Flow' den neuen Flow als Browser-Flow setzen
7) Prüft, ob euer Benutzer mit der Lieblingsfarbe rot nun Access Denied als Meldung erhält, wenn er sich in die Account Console einloggen will. (http://localhost:8080/realms/labrealm/account/)
8) Prüft, ob der Login erfolgreich ist, wenn ihr dem Benutzer zuvor eine andere Lieblingsfarbe zuweist.

## EN

1) Start the lab via `docker compose up`.
2) Create a new realm and a user in the realm.
3) Add a new attribute with the name `color` to the user profile in the realm settings. Use the permissions in the creation dialog to make the attribute visible and editable by User & Admin.
4) Open your previously created user under User and set his favorite `color` to a value, e.g. `red`.
5) Duplicate the browser flow under Authentication via the three-dot menu and adjust it so that users with `color==red` are set to `Access Denied`.
   * To do this, add a step with the name `color-step` below the username password form via + -> Add Sub Flow. You can place it directly under the Username Password Form via Drag&Drop. It should be marked as conditional.
   * Add a condition `user attribute` to `color-step` and configure the attribute name to `color` and the expected attribute value to `red` via the gear icon.
   * Add a execution `Deny Access` to `color-step`.
   * Set the condition and your Deny Access step as Required.
6) Set new flow via 'Bind Flow' as new Browser Flow.
7) Check whether your user with the favorite color red now receives Access Denied as a message when he tries to log in to the Account Console. (http://localhost:8080/realms/labrealm/account/)
8) Check whether the login is successful if you have previously assigned a different favorite color to the user.
