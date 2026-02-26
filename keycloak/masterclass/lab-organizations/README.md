# Lab Organizations

# DE

Ziel: Da wir für unser Beispiel keine externen Identity Provider nutzen können, legen wir 2 Realms an die jeweils ein Identity Provider repräsentieren. Anschließend legen wir einen weiteren Realm an, den wir für unser Multi-Tendency Setup nutzen wollen, der im Rahmen von zwei Organizations die Benutzer anhand ihrer E-Mail Adresse unterscheiden und an den richtigen Identity Provider weiter leiten soll.

## Erster Teil: Vorbereitung

1) Lege 3 Realms an: "multi", "kunde_a" und "kunde_b".
2) Aktiviere im "multi" Realm unter "Realm settings" -> "General" das Feld "Organizations".
3) Aktiviere in allen Realms unter "Realm settings" -> "Login" das Feld "Email as username".
4) Lege in den Realms "kunde_a" und "kunde_b" jeweils einen Benutzer vollständig an, inklusive Passwort. Die E-Mail-Adresse der Benutzer sollte sich eindeutig dem Kunden zuordnen lassen (z. B. "stefan@kunde-a.test" und "jens@kunde-b.test"). 
5) Richte in den beiden Kunden-Realms jeweils einen Client "multi" inklusive aktivierter Client Authentication ein.
6) Konfiguriere im "multi"-Realm die beiden anderen Realms als "Keycloak OpenID Connect provider". Der Discovery Endpoint lautet http://localhost:8080/realms/kunde_a/.well-known/openid-configuration bzw. http://localhost:8080/realms/kunde_b/.well-known/openid-configuration. Nutze als Client und Client Secret die Informationen aus den zuvor eingerichteten "multi"-Clients. 
7) Erstelle im "multi"-Realm zwei Organizations mit den Namen "kunde_a" bzw. "kunde_b" die die Domains "kunde-a.test" bzw. "kunde-b.test" nutzen. Verbinde dann mit der jeweiligen Organization den zugehörigen Identity Provider. Wähle dort auch die Domain und die beiden Optionen "Hide on login page" sowie "Redirect when email domain matches" aus.  

## Zweiter Teil: Login

1) Versuche dich jetzt auf der Account Konsole des "multi"-Realms einzuloggen: http://localhost:8080/realms/multi/account/ 
2) Gebe dazu die E-Mail-Adresse eines der beiden Kundenbenutzern ein. Im Anschluss kannst du sehen, wie eine automatische Weiterleitung zum korrekten Identity Provider passiert. Das kannst du daran erkennen, dass der Realm des ausgewählten Benutzers nun als Name in der URL Zeile erscheint. Auf dieser Seite wirst du dann dazu aufgefordert, auch das Passwort einzugeben. 
3) Hast du dich nun korrekt eingeloggt, erfolgt eine Weiterleitung zurück in den "multi"-Realm und auf die Account Konsole des "multi"-Realms.

Was ist jetzt genau passiert? Wir haben zwei Identity Provider konfiguriert, die jeweils eine Organization zugehörig sind. Versuchst du dich nun in den Realm einzuloggen, denen die Organizations zugehörig sind, wirst du über die Domain der eingegebenen Mail-Adresse automatisch einer Organization zugeordnet. Dadurch kann der korrekte Identity Provider ausgewählt werden und du kannst dich dort einloggen. Anschließend bist du im ursprünglichen Realm eingeloggt.

---

# EN

Goal: Since we cannot use external identity providers for our example, we will create 2 realms that each represent an identity provider. Then we will create another realm that we want to use for our multi-tenancy setup, which will distinguish users based on their email address within two organizations and redirect them to the correct identity provider.

## Part One: Preparation

1) Create 3 realms: "multi", "kunde_a" and "kunde_b".
2) Enable the "Organizations" field in the "multi" realm under "Realm settings" -> "General".
3) Enable the "Email as username" field in all realms under "Realm settings" -> "Login".
4) In the "kunde_a" and "kunde_b" realms, create a complete user including password. The email address of the users should be clearly assigned to the customer (e.g. "stefan@kunde-a.test" and "jens@kunde-b.test").
5) Set up a client "multi" with enabled Client Authentication in both customer realms.
6) Configure the two other realms as "Keycloak OpenID Connect provider" in the "multi" realm. The Discovery Endpoint is http://localhost:8080/realms/kunde_a/.well-known/openid-configuration and http://localhost:8080/realms/kunde_b/.well-known/openid-configuration respectively. Use the information from the previously configured "multi" clients as Client and Client Secret.
7) Create two organizations in the "multi" realm named "kunde_a" and "kunde_b" that use the domains "kunde-a.test" and "kunde-b.test" respectively. Then connect the corresponding identity provider to each organization. Also select the domain and both options "Hide on login page" and "Redirect when email domain matches".

## Part Two: Login

1) Now try to log in to the Account Console of the "multi" realm: http://localhost:8080/realms/multi/account/
2) Enter the email address of one of the two customer users. Afterwards you can see how an automatic redirect to the correct identity provider happens. You can recognize this by the fact that the realm of the selected user now appears as a name in the URL bar. On this page you will then be prompted to enter the password as well.
3) Once you have logged in correctly, you will be redirected back to the "multi" realm and to the Account Console of the "multi" realm.

What exactly happened? We configured two identity providers, each associated with an organization. When you now try to log in to the realm to which the organizations belong, you are automatically assigned to an organization via the domain of the entered email address. This allows the correct identity provider to be selected and you can log in there. Afterwards you are logged in to the original realm.
