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
    ./kcadm.sh config credentials --server http://keycloak:8080 --realm master --user admin --password admin
    PATH=$PATH:$(pwd) ./initialize-benchmark-entities.sh -r benchmark-realm -c gatling -u user-0
   ```

   **Erklärung der Parameter:**
   - `-r benchmark-realm`: Name des Realms
   - `-c gatling`: Name des Clients
   - `-u user-0`: Präfix für Benutzernamen

6) Überprüfen Sie in der Admin Console (`http://localhost:8080`), ob das Realm `benchmark-realm` mit einem Benutzer erstellt wurde.

7) Führen Sie den ersten Benchmark-Test mit **150 Benutzern pro Sekunde** durch:
   ```bash
   ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm  --users-per-sec=150 --measurement=20
   ```

   Dieser Test simuliert 150 Benutzer pro Sekunde, die sich über den OAuth2 Authorization Code Flow anmelden (20 Sekunden Messung).

8) Warten Sie, bis der Test abgeschlossen ist (~30-40 Sekunden total). Die Ergebnisse werden in `/workspace/results/` gespeichert.

9) Führen Sie den zweiten Benchmark-Test mit **180 Benutzern pro Sekunde** durch:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm  --users-per-sec=180 --measurement=20
    ```

10) Führen Sie den dritten Benchmark-Test mit **200 Benutzern pro Sekunde** durch:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm  --users-per-sec=200 --measurement=20
    ```

11) Nach jedem Test sehen Sie eine Ausgabe wie:
    ```
    Please open the following file://workspace/results/authorizationcode-20260223123456789/index.html
    ```

12) Öffnen Sie die HTML-Berichte in Ihrem Browser, indem Sie die Datei per Rechts-Klick mit der Live-Server Erweiterung öffnen

13) Vergleichen Sie die drei Tests und achten Sie auf folgende Metriken:

    **a) Request-Metriken (Global Information):**
    - Total Requests
    - OK / KO (Fehler)
    - Mean Response Time (Durchschnitt)
    - **95th percentile (P95)**
    - **99th percentile (P99)**

    **c) Requests per Second:**
    - Wie viele Benutzer-Logins pro Sekunde kann das aktuelle Setup verarbeiten?
    - Ab wann ist die Performance für Benutzer unzumutbar?

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
    ./kcadm.sh config credentials --server http://keycloak:8080 --realm master --user admin --password admin
    PATH=$PATH:$(pwd) ./initialize-benchmark-entities.sh -r benchmark-realm -c gatling -u user-0
   ```

   **Parameter explanation:**
   - `-r benchmark-realm`: Realm name
   - `-c gatling`: Client name
   - `-u user-0`: User name prefix

6) Verify in the Admin Console (`http://localhost:8080`) that the realm `benchmark-realm` with one user has been created.

7) Run the first benchmark test with **150 users per second**:
   ```bash
   ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm  --users-per-sec=150 --measurement=20
   ```

   This test simulates 150 users per second logging in via OAuth2 Authorization Code Flow (20 seconds measurement).

8) Wait until the test completes (~30-40 seconds total). Results are saved to `/workspace/results/`.

9) Run the second benchmark test with **180 users per second**:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm  --users-per-sec=180 --measurement=20
    ```

10) Run the third benchmark test with **200 users per second**:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm  --users-per-sec=200 --measurement=20
    ```

11) After each test, you'll see output like:
    ```
    Please open the following file://workspace/results/authorizationcode-20260223123456789/index.html
    ```

12) Open the HTML reports in your browser by right-clicking the file and opening it with the Live Server extension

13) Compare the three tests and focus on these metrics:

    **a) Request Metrics (Global Information):**
    - Total Requests
    - OK / KO (errors)
    - Mean Response Time (average)
    - **95th percentile (P95)**
    - **99th percentile (P99)**

    **c) Requests per Second:**
    - How many user logins per second can the current setup handle?
    - At what point does performance become unacceptable for users?

### What Should You See?

14) **Expected Observations:**

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
