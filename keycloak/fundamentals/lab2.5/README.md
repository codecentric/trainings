# Lab 2.5

1) Startet das Lab via `docker compose up`.
2) Legt einen neuen Realm und einen Benutzer im Realm an.
3) Fügt in den Realm settings dem User profile ein neues Attribut mit dem Namen `farbe` hinzu. Nutzt die Permissions im Erstellungsdialog um das Attribut durch User & Admin einsehbar und editierbar zu machen.
4) Öffnet unser User euren zuvor erstellten Benutzer und setzt dort seine Lieblings-`farbe` auf einen Wert, z. B. `rot`.
5) Dupliziert unter Authentication über das Drei-Punkte-Menü den Browser Flow und passt ihn so an, dass Benutzer mit `farbe==rot` auf `Access Denied` kommen.
   * Fügt dazu unterhalb des Username Passwort Forms via + -> Add Sub Flow einen Schritt mit dem Namen `farbe-step` hinzu. Ihr könnt es via Drag&Drop direkt unter dem Username Passwort Form platzieren.
   * Fügt `farbe-step` eine Condition `user attribute` hinzu und konfiguriert via Zahnrad-Symbol den Attribute name auf `farbe` und den Expected attribute value auf `rot`.
   * Fügt `farbe-step` einen Step `Access Denied` hinzu.
   * Setzt die Condition und eurem Access Denied Step als Required.
6) Prüft, ob euer Benutzer mit der Lieblingsfarbe rot nun Access Denied als Meldung erhält, wenn er sich in die Account Console einloggen will.
7) Prüft, ob der Login erfolgreich ist, wenn ihr dem Benutzer zuvor eine andere Lieblingsfarbe zuweist.