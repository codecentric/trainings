# Lab Benchmarking

## DE

In diesem Lab lernen Sie, wie Sie Keycloak unter Last testen und die Ergebnisse interpretieren. Sie werden die Performance-Charakteristiken von Keycloak analysieren, indem Sie unterschiedliche Lastniveaus verwenden und die Auswirkungen auf Antwortzeiten beobachten.

1) Starten Sie die Keycloak-Umgebung und die VS-Code-Umgebung im Projekt-Root-Verzeichnis mit `docker compose up`.
   Sobald die Container laufen, öffnen Sie die VS-Code-Umgebung im Browser unter `http://localhost:3000`.
   Verwenden Sie diese VS-Code-Umgebung (integriertes Terminal), um alle Befehle im Rahmen des Labs auszuführen.

2) Sobald Keycloak läuft, öffnen Sie es im Browser unter `http://localhost:8080`.

3) Warten Sie, bis Keycloak vollständig gestartet ist (Admin Console erreichbar unter `http://localhost:8080`).

4) Öffnen Sie das Terminal in VS Code (im Browser) und navigieren Sie zum Scripts-Verzeichnis:
   ```bash
   cd /workspace/scripts
   ```

5) Importieren Sie ein Realm mit 200 Testbenutzern:
   ```bash
   ./dataset-import.sh -a create-realms -r 1 -n realm-0 -c 10 -u 200 -l 'http://keycloak:8080/realms/master/dataset'
   ```

   **Erklärung der Parameter:**
   - `-a create-realms`: Aktion - erstelle Realms
   - `-r 1`: Anzahl der Realms (1)
   - `-n realm-0`: Name des Realms
   - `-c 10`: Anzahl der Clients (10)
   - `-u 200`: Anzahl der Benutzer (200)
   - `-l`: Keycloak-URL (interner Container-Hostname)

6) Warten Sie, bis der Import abgeschlossen ist (kann 1-2 Minuten dauern).

7) Überprüfen Sie in der Admin Console (`http://localhost:8080`), ob das Realm `realm-0` mit 200 Benutzern erstellt wurde.

8) Führen Sie den ersten Benchmark-Test mit **150 Benutzern pro Sekunde** durch:
   ```bash
   ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode \
     --users-per-sec=150 --measurement=20
   ```

   Dieser Test simuliert 150 Benutzer pro Sekunde, die sich über den OAuth2 Authorization Code Flow anmelden (20 Sekunden Messung).

9) Warten Sie, bis der Test abgeschlossen ist (~30-40 Sekunden total). Die Ergebnisse werden in `/workspace/results/` gespeichert.

10) Führen Sie den zweiten Benchmark-Test mit **180 Benutzern pro Sekunde** durch:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode \
      --users-per-sec=180 --measurement=20
    ```

11) Führen Sie den dritten Benchmark-Test mit **200 Benutzern pro Sekunde** durch:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode \
      --users-per-sec=200 --measurement=20
    ```

12) Nach jedem Test sehen Sie eine Ausgabe wie:
    ```
    Please open the following file://workspace/results/authorizationcode-20260223123456789/index.html
    ```

13) Öffnen Sie die HTML-Berichte in Ihrem Browser, indem Sie die Datei über VS Code Web öffnen oder die Dateien im Verzeichnis `/workspace/results/` suchen.

14) Vergleichen Sie die drei Tests und achten Sie auf folgende Metriken:

    **a) Request-Metriken (Global Information):**
    - Total Requests
    - OK / KO (Fehler)
    - Mean Response Time (Durchschnitt)
    - **95th percentile (P95)**
    - **99th percentile (P99)**

    **b) Response Time Distribution:**
    - Wie viele Anfragen waren < 800ms?
    - Wie viele Anfragen waren > 1200ms oder fehlgeschlagen?

    **c) Requests per Second:**
    - Konnte Keycloak die gewünschte Last verarbeiten?

### Was sollten Sie sehen?

15) **Erwartete Beobachtungen:**

    - **Bei 150 users/sec:**
      - Niedrige Fehlerrate (< 1%)
      - P95 Latenz: ~500-800ms
      - Stabile Performance

    - **Bei 180 users/sec:**
      - Moderate Fehlerrate (1-5%)
      - P95 Latenz: ~800-1200ms
      - Erste Anzeichen von Überlastung

    - **Bei 200 users/sec:**
      - Höhere Fehlerrate (5-15%+)
      - P95 Latenz: > 1200ms oder Timeouts
      - Deutliche Überlastung, viele Anfragen scheitern

    **Kernfrage:** Ab welchem Load-Level beginnt Keycloak zu "strugglen"?
    Beobachten Sie, wie die P95/P99-Latenzen exponentiell steigen und Fehlerraten zunehmen.

---

## EN

In this lab, you will learn how to load test Keycloak and interpret the results. You will analyze Keycloak's performance characteristics by using different load levels and observing the impact on response times.

1) Start the Keycloak environment and the VS Code environment from the project root directory using `docker compose up`.
   Once the containers are running, open the VS Code environment in your browser at `http://localhost:3000`.
   Use this VS Code environment (integrated terminal) to run all commands for this lab.

2) Once Keycloak is running, open it in your browser at `http://localhost:8080`.

3) Wait until Keycloak is fully started (Admin Console accessible at `http://localhost:8080`).

4) Open the terminal in VS Code (in browser) and navigate to the scripts directory:
   ```bash
   cd /workspace/scripts
   ```

5) Import a realm with 200 test users:
   ```bash
   ./dataset-import.sh -a create-realms -r 1 -n realm-0 -c 10 -u 200 -l 'http://keycloak:8080/realms/master/dataset'
   ```

   **Parameter explanation:**
   - `-a create-realms`: Action - create realms
   - `-r 1`: Number of realms (1)
   - `-n realm-0`: Realm name
   - `-c 10`: Number of clients (10)
   - `-u 200`: Number of users (200)
   - `-l`: Keycloak URL (internal container hostname)

6) Wait until the import is complete (may take 1-2 minutes).

7) Verify in the Admin Console (`http://localhost:8080`) that the realm `realm-0` with 200 users has been created.

8) Run the first benchmark test with **150 users per second**:
   ```bash
   ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode \
     --users-per-sec=150 --measurement=20
   ```

   This test simulates 150 users per second logging in via OAuth2 Authorization Code Flow (20 seconds measurement).

9) Wait until the test completes (~30-40 seconds total). Results are saved to `/workspace/results/`.

10) Run the second benchmark test with **180 users per second**:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode \
      --users-per-sec=180 --measurement=20
    ```

11) Run the third benchmark test with **200 users per second**:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode \
      --users-per-sec=200 --measurement=20
    ```

12) After each test, you'll see output like:
    ```
    Please open the following file://workspace/results/authorizationcode-20260223123456789/index.html
    ```

13) Open the HTML reports in your browser by opening the file via VS Code Web or browsing the `/workspace/results/` directory.

14) Compare the three tests and focus on these metrics:

    **a) Request Metrics (Global Information):**
    - Total Requests
    - OK / KO (errors)
    - Mean Response Time (average)
    - **95th percentile (P95)**
    - **99th percentile (P99)**

    **b) Response Time Distribution:**
    - How many requests were < 800ms?
    - How many requests were > 1200ms or failed?

    **c) Requests per Second:**
    - Could Keycloak handle the desired load?

### What Should You See?

15) **Expected Observations:**

    - **At 150 users/sec:**
      - Low error rate (< 1%)
      - P95 latency: ~500-800ms
      - Stable performance

    - **At 180 users/sec:**
      - Moderate error rate (1-5%)
      - P95 latency: ~800-1200ms
      - First signs of overload

    - **At 200 users/sec:**
      - Higher error rate (5-15%+)
      - P95 latency: > 1200ms or timeouts
      - Clear overload, many requests fail

    **Key Question:** At what load level does Keycloak start to struggle?
    Observe how P95/P99 latencies increase exponentially and error rates rise.
