# Lab ABAC

## Erster Teil: Basiskonfiguration

Ziel: Wir wollen eine Regel definieren, die Benutzern, die Mitglied einer bestimmten Gruppe sind, Zugriff auf eine Ressource erlauben.

1) Bitte öffnet die in diesem Verzeichnis liegende Datei `docker-compose.yaml` und macht euch mit der Konfiguration vertraut.
2) Wechselt auf der Kommandozeile in diesen Ordner und führt `docker compose up` aus.
3) Öffnet in eurem Browser die URL http://localhost:8080 und loggt euch mit den Credentials `admin`/`admin` ein.
4) Legt einen neuen "lab-realm" an und wechselt in diesen.
5) Legt einen neuen Benutzer an und weist ihm ein Department zu. Lege auch eine neue Gruppe "test-gruppe" an, in der der Benutzer Mitglied ist.
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
3) Lege für den JS-Provider eine weitere Policy an. Dabei musst du nur einen Namen festlegen - die Logik ist im JS-Code!
4) Füge deiner Permission die angelegt Policy hinzu.
5) Wenn du jetzt "Evaluate" nutzt, erhälst du ein "Deny". Passe deinen Benutzer so an, dass das "Evaluate" zu "Permit" evaluiert.