# Lab X.Y

## DE

### Erster Teil: Admin API

1) Starten Sie die Keycloak-Umgebung und die VS-Code-Umgebung im Projekt-Root-Verzeichnis mit `docker compose up`.  
   Sobald die Container laufen, öffnen Sie die VS-Code-Umgebung im Browser unter `http://localhost:3000`.  
   Verwenden Sie diese VS-Code-Umgebung (integriertes Terminal), um alle curl-Aufrufe im Rahmen des Labs auszuführen.
2) Sobald Keycloak läuft, öffnen Sie es im Browser unter `http://localhost:8080`.
3) Öffnen Sie die **Keycloak Admin Console** und melden Sie sich mit den im `docker-compose.yml` definierten Admin-Zugangsdaten an.
4) Erstellen Sie ein neues Realm mit dem Namen `lab-realm`.
5) Erstellen Sie innerhalb des Realms `lab-realm` einen neuen Client:
   - Client ID: `lab-admin-client`
   - Client-Authentifizierung: **Aktiviert**
   - Authorization: **Deaktiviert**
   - Service Account Roles: **Aktiviert**
   - Access Type: **Confidential**
   - Speichern Sie den Client.
6) Navigieren Sie nach dem Speichern zum Tab **Service Account Roles** des Clients.  
   Weisen Sie dem Service Account folgende Rollen aus `realm-management` zu:
   - `manage-users`
   - `view-users`
7) Wechseln Sie zum Tab **Credentials** des Clients und kopieren Sie das generierte **Client Secret**.  
   Dieses benötigen Sie, um über die Admin API ein Access Token zu erhalten.
8) Verwenden Sie in VS Code (oder im Terminal) folgenden curl-Befehl, um über den Client-Credentials-Grant ein Access Token zu erhalten:  
   `curl -X POST "keycloak:8080/realms/lab-realm/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials" -d "client_id=lab-admin-client" -d "client_secret=<IHR_CLIENT_SECRET>"`
   Kopieren Sie das `access_token` aus der Antwort.
9) Verwenden Sie das erhaltene `access_token`, um über die Admin REST API einen neuen Benutzer zu erstellen:  
   `curl -X POST "keycloak:8080/admin/realms/lab-realm/users" -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" -d '{"username":"student1","enabled":true,"requiredActions":["UPDATE_PASSWORD"]}'`
10) Überprüfen Sie in der Admin Console, ob der Benutzer `student1` im Realm `lab-realm` erfolgreich erstellt wurde.
11) Öffnen Sie die Account Console des Realms im Browser:  
   `http://localhost:8080/realms/lab-realm/account`
12) Melden Sie sich als `student1` an.  
    Da für den Benutzer die Required Action `UPDATE_PASSWORD` gesetzt wurde, sollten Sie beim ersten Login zur Passwortänderung aufgefordert werden.
13) Aktualisieren Sie das Passwort und prüfen Sie anschließend, ob Sie erfolgreich auf die Account Console zugreifen können.
14) (Optional) Rufen Sie über die Admin API die Benutzerliste per GET ab:  
   `curl -X GET "keycloak:8080/admin/realms/lab-realm/users" -H "Authorization: Bearer <ACCESS_TOKEN>"`
   Prüfen Sie, ob im Feld `requiredActions` der Wert `UPDATE_PASSWORD` enthalten ist.

### Zweiter Teil: Account API
1) Stellen Sie sicher, dass Sie Teil 1 erfolgreich abgeschlossen haben und der Benutzer `student1` im Realm `lab-realm` existiert.
2) Öffnen Sie das offizielle Keycloak Open-Source-Repository auf GitHub:  
   https://github.com/keycloak/keycloak
3) Navigieren Sie innerhalb des Keycloak-Repositorys zum Account-UI-Projekt:  
   https://github.com/keycloak/keycloak/tree/main/js/apps/account-ui

   Analysieren Sie, wie das Frontend die Aktualisierung des Benutzerprofils auslöst:
   - Welche Funktion führt das Update aus?
   - Welcher Endpoint wird aufgerufen?
   - Wie ist das Payload (Request-Body) strukturiert?
4) Bestimmen Sie auf Grundlage Ihrer Source-Code-Analyse:
   - Den korrekten Account-API-Endpoint  
   - Die richtige HTTP-Methode  
   - Den erforderlichen JSON-Body zur Aktualisierung von `firstName` und `lastName`  
5) Fordern Sie ein User-Access-Token für `student1` mithilfe des Resource-Owner-Password-Grant an:  
   `curl -X POST "keycloak:8080/realms/lab-realm/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password" -d "client_id=account-console" -d "username=student1" -d "password=<STUDENT_PASSWORD>"`

   Kopieren Sie das `access_token` aus der Antwort.
6) Verwenden Sie den im Source Code identifizierten Endpoint und die entsprechende Payload-Struktur, um einen curl-Request zu erstellen, der folgende Felder aktualisiert:
   - `firstName`
   - `lastName`

   Verwenden Sie das `access_token` im Header `Authorization: Bearer`.
7) Überprüfen Sie Ihr Ergebnis, indem Sie den Benutzer über die Admin API abrufen und bestätigen, dass die Attribute `firstName` und `lastName` aktualisiert wurden.

## EN

### Part One: Admin API

1) Start the Keycloak environment and the VS Code environment from the project root directory using `docker compose up`.  
   Once the containers are running, open the VS Code environment in your browser at `http://localhost:3000`.  
   Use this VS Code environment (integrated terminal) to perform all curl requests for the lab exercises.
2) Once Keycloak is running, open it in your browser at `http://localhost:8080`.
3) Open the **Keycloak Admin Console** and log in with the admin credentials defined in your `docker-compose.yml`.
4) Create a new realm named `lab-realm`.
5) Inside the realm `lab-realm`, create a new client:
   - Client ID: `lab-admin-client`
   - Client authentication: **Enabled**
   - Authorization: **Disabled**
   - Service accounts roles: **Enabled**
   - Access type: **Confidential**
   - Save the client.
6) After saving, navigate to the **Service Account Roles** tab of the client.  
   Assign the following realm-management roles to the service account:
   - `manage-users`
   - `view-users`
7) Navigate to the **Credentials** tab of the client and copy the generated **Client Secret**.  
   You will need this secret to obtain an access token via the Admin API.
8) Using VS Code (or a terminal), obtain an access token via curl using the Client Credentials Grant:  
   `curl -X POST "keycloak:8080/realms/lab-realm/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials" -d "client_id=lab-admin-client" -d "client_secret=<YOUR_CLIENT_SECRET>"`
   Copy the `access_token` from the response.
9) Use the obtained `access_token` to create a new user via the Admin REST API:  
   `curl -X POST "keycloak:8080/admin/realms/lab-realm/users" -H "Content-Type: application/json" -H "Authorization: Bearer <ACCESS_TOKEN>" -d '{"username":"student1","enabled":true,"requiredActions":["UPDATE_PASSWORD"]}'`
10) Verify in the Admin Console that the user `student1` has been created successfully in the realm `lab-realm`.
11) Open the Account Console for the realm in your browser:  
   `http://localhost:8080/realms/lab-realm/account`
12) Log in as `student1`.  
    Since the user has the required action `UPDATE_PASSWORD`, you should be prompted to update the password before accessing the account console.
13) After updating the password, verify that you can access the account console successfully.
14) (Optional) Use the Admin API to retrieve the created user via GET:  
   `curl -X GET "keycloak:8080/admin/realms/lab-realm/users" -H "Authorization: Bearer <ACCESS_TOKEN>"`
   Confirm that the `requiredActions` field does not contain `UPDATE_PASSWORD` anymore.

### Part 2 - Account API

1) Make sure you have successfully completed Part 1 and that the user `student1` exists in the realm `lab-realm`.
2) Open the official Keycloak open-source repository on GitHub:  
   https://github.com/keycloak/keycloak
3) Navigate to the Account UI project inside the Keycloak repository:  
   https://github.com/keycloak/keycloak/tree/main/js/apps/account-ui

   Analyze how the frontend triggers the profile update:
   - Which function performs the update?
   - Which endpoint is called?
   - How is the payload structured?
4) Based on your source code analysis, determine:
   - The correct Account API endpoint  
   - The correct HTTP method  
   - The required JSON body to update `firstName` and `lastName`  
5) Obtain a user access token for `student1` using the Resource Owner Password Grant:  
   `curl -X POST "keycloak:8080/realms/lab-realm/protocol/openid-connect/token" -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=password" -d "client_id=account-console" -d "username=student1" -d "password=<STUDENT_PASSWORD>"`

   Copy the `access_token` from the response.
6) Using the endpoint and payload structure you identified in the source code, construct a curl request to update:
   - `firstName`
   - `lastName`

   Use the `access_token` in the `Authorization: Bearer` header.
7) Verify your result by retrieving the user via the Admin API and confirming that the attributes `firstName` and `lastName` have been updated.
