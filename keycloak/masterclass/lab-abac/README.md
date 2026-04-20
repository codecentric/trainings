# Lab ABAC

## DE

Ziel: Ihr lernt, wie ihr in Keycloak attributbasierte Zugriffskontrolle (ABAC) mit Gruppen-Policies und eigenen JavaScript-Policies umsetzt, um feingranularen Zugriff auf Ressourcen zu steuern.

## Erster Teil: Basiskonfiguration

Ziel: Wir wollen eine Regel definieren, die Benutzern, die Mitglied einer bestimmten Gruppe sind, Zugriff auf eine Ressource erlauben.

1) Bitte öffnet die in diesem Verzeichnis liegende Datei `docker-compose.yaml` und macht euch mit der Konfiguration vertraut.
2) Wechselt auf der Kommandozeile in diesen Ordner und führt `docker compose up` aus.
3) Öffnet in eurem Browser die URL http://localhost:8080 und loggt euch mit den Credentials `admin`/`admin` ein.
4) Legt einen neuen "lab-realm" an und wechselt in diesen.
5) Legt einen neuen Benutzer an. Lege eine neue Gruppe "test-gruppe" an, in der der Benutzer Mitglied ist.
6) Legt einen neuen Client "lab-client" an. Aktiviert dabei "Client authentication" und "Authorization".
7) Wechselt in den "Authorization"-Tab des Clients.
   - Legt unter "Resources" ein Element an und setzt "Name" und "Display name" auf "test-ressource".
   - Legt unter "Policies" ein Element vom Typ "Group" an und setze den Namen "test-gruppe-policy" und füge via "Add groups" die "test-gruppe" hinzu.
   - Verknüpfe nun Resource und Policy indem du eine Resource Based Permission anlegst. Gebe ihr einen Namen und weise Resource und Policy hinzu.
8) Via "Evaluate" kannst du nun prüfen, ob dein Benutzer nun Zugriff auf die Resource hat. Wähle dort unter Users deinen Benutzer und unter Roles "default-roles-lab-realm" aus und klicke auf "Evaluate". Du solltest für die Resource "test-ressource" ein "Permit" erhalten.

## Zweiter Teil: Eigene Regeln definieren

Ziel: Wir wollen eigene Policies implementieren, die mehr Logik enthalten können und zum Beispiel Profil-Attribute auswerten.

1) Legt im "User Profile" in den "Realm settings" ein neues Attribut mit dem Namen "department" so an, dass es für Benutzer und Admin les- und schreibbar ist.
2) Im Ordner Providers findest du eine Implementierung für einen selbst gebauten JavaScript provider. Schaue dir die Datei providers.js genau an und schau, was darin passiert.
3) Lege den JS-Provider als weitere Policy in deinem Client an. Dabei musst du nur einen Namen festlegen - die Logik ist im JS-Code!
4) Füge deiner Permission die angelegt Policy hinzu.
5) Wenn du jetzt "Evaluate" nutzt, erhälst du ein "Deny". Passe deinen Benutzer so an, dass das "Evaluate" zu "Permit" evaluiert.

---

## EN

Goal: You will learn how to implement attribute-based access control (ABAC) in Keycloak using group policies and custom JavaScript policies to control fine-grained access to resources.

## Part One: Basic Configuration

Goal: We want to define a rule that grants users who are members of a specific group access to a resource.

1) Please open the `docker-compose.yaml` file in this directory and familiarize yourself with the configuration.
2) Navigate to this folder on the command line and run `docker compose up`.
3) Open the URL http://localhost:8080 in your browser and log in with the credentials `admin`/`admin`.
4) Create a new "lab-realm" and switch to it.
5) Create a new user and assign a department to them. Also create a new group "test-group" and make the user a member of it.
6) Create a new client "lab-client". Enable "Client authentication" and "Authorization".
7) Switch to the "Authorization" tab of the client.
   - Under "Resources", create an element and set "Name" and "Display name" to "test-resource".
   - Under "Policies", create an element of type "Group", set the name to "test-group-policy" and add the "test-group" via "Add groups".
   - Now link the resource and policy by creating a Resource Based Permission. Give it a name and assign the resource and policy to it.
8) Via "Evaluate", you can now check whether your user has access to the resource. Select your user under "Users" and "default-roles-lab-realm" under "Roles", then click "Evaluate". You should receive a "Permit" for the resource "test-resource".

## Part Two: Defining Custom Rules

Goal: We want to implement our own policies that can contain more logic, for example, evaluating profile attributes.

1) In the "User Profile" section of the "Realm settings", create a new attribute named "department" so that it is readable and writable for users and admins.
2) In the Providers folder, you'll find an implementation for a custom JavaScript provider. Take a close look at the providers.js file and see what happens in it.
3) Create the JS provider as another policy in your client. You only need to set a name - the logic is in the JS code!
4) Add the newly created policy to your permission.
5) If you now use "Evaluate", you'll get a "Deny". Adjust your user so that "Evaluate" evaluates to "Permit".
