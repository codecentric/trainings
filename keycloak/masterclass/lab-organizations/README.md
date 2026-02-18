# Lab Organizations

Ziel: Da wir für unser Beispiel keine externen Identity Provider nutzen können, legen wir 2 Realms an die jeweils ein Identity Provider repräsentieren. Anschließend legen wir einen weiteren Realm an, den wir für unser Multi-Tendency Setup nutzen wollen, der im Rahmen von zwei Organizations die Benutzer anhand ihrer E-Mail Adresse unterscheiden und an den richtigen Identity Provider weiter leiten soll. 

## Erster Teil: Vorbereitung

1) Lege 3 Realms an: "multi", "kunde_a" und "kunde_b".
2) Aktiviere im "multi" Realm unter "Realm settings" -> "General" das Feld "Organizations".
3) Aktiviere in allen Realms unter "Realm settings" -> "Login" das Feld "Email as username".
4) Lege in [Keycloak Administration Console.url](../../../../../AppData/Local/Temp/Keycloak%20Administration%20Console.url)den Realms "kunde_a" und "kunde_b" jeweils einen Benutzer vollständig an inklusive Passwort. Die E-Mail-Adresse der Benutzer sollte sich eindeutig dem Kunden zuordnen lassen (z. B. "stefan@kunde-a.test" und "jens@kunde-b.test"). 
5) Rechte in den beiden Kunden-Realms jeweils einen Client "multi" inklusive aktivierter Client Authentication ein.
6) Konfiguriere im "multi"-Realm die beiden anderen Realms als "Keycloak OpenID Connect provider". Der Discovery Endpoint lautet http://localhost:8080/realms/kunde_a/.well-known/openid-configuration bzw. http://localhost:8080/realms/kunde_b/.well-known/openid-configuration. Nutze als Client und Client Secret die Informationen aus den zuvor eingerichteten "multi"-Clients. 
7) Erstelle im "multi"-Realm zwei Organizations mit den Namen "kunde_a" bzw. "kunde_b" die die Domains "kunde-a.test" bzw. "kunde-b.test" nutzen. Verbinde dann mit der jeweiligen Organization den zugehörigen Identity Provider. Wähle dort auch die Domain und die beiden Optionen "Hide on login page" sowie "Redirect when email domain matches" aus.  

## Zweiter Teil: Login

1) Versuche dich jetzt auf der Account Konsole des "multi"-Realms einzuloggen: http://localhost:8080/realms/multi/account/ 
2) Gebe dazu die E-Mail-Adresse eines der beiden Kundenbenutzern ein. Im Anschluss kannst du sehen, wie eine automatische Weiterleitung zum korrekten Identity Provider passiert. Das kannst du daran erkennen, dass der Realm des ausgewählten Benutzers nun als Name in der URL Zeile erscheint. Auf dieser Seite wirst du dann dazu aufgefordert, auch das Passwort einzugeben. 
3) Hast du dich nun korrekt eingeloggt, erfolgt eine Weiterleitung zurück in den "multi"-Realm und auf die Account Konsole des "multi"-Realms.

Was ist jetzt genau passiert? Wir haben zwei Identity Provider konfiguriert, die jeweils eine Organization zugehörig sind. Versuchst du dich nun in den Realm einzuloggen, denen die Organizations zugehörig sind, wirst du über die Domain der eingegebenen Mail-Adresse automatisch einer Organization zugeordnet. Dadurch kann der korrekte Identity Provider ausgewählt werden und du kannst dich dort einloggen. Anschließend bist du im ursprünglichen Realm eingeloggt. 