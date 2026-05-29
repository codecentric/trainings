# Dynamic Client Registration

## DE

### Erster Teil: Anonyme Client-Registrierung mit Trusted Hosts Policy

In diesem Teil registriert ihr einen Client ohne jegliche Authentifizierung. Die **Trusted Hosts Policy** steuert dabei, von welchen Hosts aus der DCR-Endpunkt aufgerufen werden darf – nicht, welche Redirect-URIs ein Client haben darf. Ihr beobachtet zunächst die Standardblockierung und entsperrt den Endpunkt dann gezielt.

1) Starten Sie die Umgebung aus dem Lab-Verzeichnis:
   ```
   docker compose up
   ```
   Als "Host" von Anfragen vom Host-Computer sieht Keycloak die IP-Adresse des Docker Gateways. Führe ``docker inspect <keycloak_container_id> --format '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}'`` aus, um die IP Adresse heraus zu finden.

2) Öffnen Sie die Keycloak Admin Console im Browser unter `http://localhost:8080`.
   Melden Sie sich mit den Admin-Zugangsdaten an (`admin` / `admin`) und erstellen Sie ein neues Realm mit dem Namen `lab-realm`.

3) Verschaffen Sie sich einen Überblick über die Client-Registrierungsrichtlinien:
   - Navigieren Sie zu **Clients → Client Registration**.
   - Unter **Anonymous Access Policies** sehen Sie die **Trusted Hosts** Policy.
   - Diese Policy prüft, von welchem Host der Registrierungsaufruf kommt. Sie ist standardmäßig aktiv, enthält aber keine eingetragenen Hosts – anonyme Registrierungen sind damit vollständig blockiert.

4) Versuchen Sie zunächst, einen Client ohne Konfiguration zu registrieren, um die Ablehnung zu sehen:
   ```
   curl -X POST "http://localhost:8080/realms/lab-realm/clients-registrations/openid-connect" \
     -H "Content-Type: application/json" \
     -d '{
       "client_name": "my-client",
       "redirect_uris": ["http://<GATEWAY_IP>/callback"],
       "grant_types": ["authorization_code"],
       "response_types": ["code"],
       "token_endpoint_auth_method": "client_secret_basic"
     }'
   ```
   Keycloak lehnt die Anfrage ab.

5) Konfigurieren Sie die **Trusted Hosts Policy**, um Aufrufe aus dem VS-Code-Container zu erlauben:
   - Klicken Sie unter **Anonymous Access Policies** auf **Trusted Hosts**.
   - Tragen Sie im Feld **Trusted Hosts** den Wert `<GATEWAY_IP>` ein.
   - Klicken Sie auf **Save**.

6) Registrieren Sie nun denselben Client erneut:
   ```
   curl -X POST "http://localhost:8080/realms/lab-realm/clients-registrations/openid-connect" \
     -H "Content-Type: application/json" \
     -d '{
       "client_name": "my-client",
       "redirect_uris": ["http://<GATEWAY_IP>:9090/callback"],
       "grant_types": ["authorization_code"],
       "response_types": ["code"],
       "token_endpoint_auth_method": "client_secret_basic"
     }'
   ```
   Diesmal sollte die Registrierung erfolgreich sein. Prüfen Sie die Antwort auf `client_id`, `client_secret` und `registration_access_token`.

7) Überprüfen Sie in der Admin Console unter **Clients**, ob der neue Client `my-client` im Realm `lab-realm` erscheint.

---

### Bonus: Client-Registrierung mit Initial Access Token

In diesem Teil registriert ihr einen Client mit einem **Initial Access Token** (IAT). Dieses Token berechtigt zur einmaligen Registrierung eines Clients und ist damit ein kontrollierter Mechanismus, der anonyme Registrierungen ersetzen oder ergänzen kann.

1) Erstellen Sie in der Admin Console einen Initial Access Token:
   - Navigieren Sie zu **Clients → Initial Access Token**.
   - Klicken Sie auf **Create**.
   - Setzen Sie eine Gültigkeitsdauer (z. B. `3600` Sekunden / 1 Stunde) und einen **Count** von `1` (einmalige Verwendung).
   - Klicken Sie auf **Save** und kopieren Sie den angezeigten Token-Wert. **Achtung**: Der Token wird nur einmal angezeigt!

2) Registrieren Sie einen Client mit dem Initial Access Token:
   ```
   curl -X POST "http://localhost:8080/realms/lab-realm/clients-registrations/openid-connect" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <IHR_INITIAL_ACCESS_TOKEN>" \
     -d '{
       "client_name": "iat-client",
       "redirect_uris": ["https://mydomain.com/callback"],
       "grant_types": ["authorization_code"],
       "response_types": ["code"],
       "token_endpoint_auth_method": "client_secret_basic"
     }'
   ```
   Ersetzen Sie `<IHR_INITIAL_ACCESS_TOKEN>` durch den Token aus Schritt 1.

3) Überprüfen Sie in der Admin Console unter **Clients**, ob `iat-client` erfolgreich erstellt wurde.

---

## EN

### Part One: Anonymous Client Registration with Trusted Hosts Policy

In this part, you register a client without any authentication. The **Trusted Hosts Policy** controls which hosts are allowed to call the DCR endpoint — not which redirect URIs a client may have. You will first observe the default blocking behaviour, then unlock the endpoint deliberately.

1) Start the environment from the lab directory:
   ```
   docker compose up
   ```
   Keycloak sees requests from the host machine as coming from the Docker Gateway IP address. Run ``docker inspect <keycloak_container_id> --format '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}'`` to find that IP address.

2) Open the Keycloak Admin Console in your browser at `http://localhost:8080`.
   Log in with the admin credentials (`admin` / `admin`) and create a new realm named `lab-realm`.

3) Get an overview of the client registration policies:
   - Navigate to **Clients → Client Registration**.
   - Under **Anonymous Access Policies**, you can see the **Trusted Hosts** policy.
   - This policy checks which host is making the registration call. It is active by default but contains no entries — anonymous registrations are completely blocked out of the box.

4) First, try to register a client without any configuration to see the rejection:
   ```
   curl -X POST "http://localhost:8080/realms/lab-realm/clients-registrations/openid-connect" \
     -H "Content-Type: application/json" \
     -d '{
       "client_name": "my-client",
       "redirect_uris": ["http://<GATEWAY_IP>/callback"],
       "grant_types": ["authorization_code"],
       "response_types": ["code"],
       "token_endpoint_auth_method": "client_secret_basic"
     }'
   ```
   Keycloak rejects the request.

5) Configure the **Trusted Hosts Policy** to allow calls from the VS Code container:
   - Under **Anonymous Access Policies**, click **Trusted Hosts**.
   - In the **Trusted Hosts** field, enter `<GATEWAY_IP>`.
   - Click **Save**.

6) Now register the same client again:
   ```
   curl -X POST "http://localhost:8080/realms/lab-realm/clients-registrations/openid-connect" \
     -H "Content-Type: application/json" \
     -d '{
       "client_name": "my-client",
       "redirect_uris": ["http://<GATEWAY_IP>:9090/callback"],
       "grant_types": ["authorization_code"],
       "response_types": ["code"],
       "token_endpoint_auth_method": "client_secret_basic"
     }'
   ```
   This time the registration should succeed. Inspect the response for `client_id`, `client_secret`, and `registration_access_token`.

7) Verify in the Admin Console under **Clients** that the new client `my-client` appears in `lab-realm`.

---

### Bonus: Client Registration with Initial Access Token

In this part, you register a client using an **Initial Access Token** (IAT). This token grants a single-use authorization to register a client – a controlled mechanism that can replace or complement anonymous registrations.

1) Create an Initial Access Token in the Admin Console:
   - Navigate to **Clients → Initial Access Token**.
   - Click **Create**.
   - Set an expiration time (e.g. `3600` seconds / 1 hour) and a **Count** of `1` (single use).
   - Click **Save** and copy the displayed token value. **Important**: The token is shown only once!

2) Register a client using the Initial Access Token:
   ```
   curl -X POST "http://localhost:8080/realms/lab-realm/clients-registrations/openid-connect" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <YOUR_INITIAL_ACCESS_TOKEN>" \
     -d '{
       "client_name": "iat-client",
       "redirect_uris": ["https://mydomain.com/callback"],
       "grant_types": ["authorization_code"],
       "response_types": ["code"],
       "token_endpoint_auth_method": "client_secret_basic"
     }'
   ```
   Replace `<YOUR_INITIAL_ACCESS_TOKEN>` with the token from step 1.

3) Verify in the Admin Console under **Clients** that `iat-client` was successfully created.
