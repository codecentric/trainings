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

5) Kreieren Sie einen Realm, der für die Benchmarks genutzt werden kann:
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
   ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm --ramp-up 5 --users-per-sec=150 --measurement=60
   ```

   Dieser Test simuliert 150 Benutzer pro Sekunde, die sich über den OAuth2 Authorization Code Flow anmelden (60 Sekunden Messung).

8) Warten Sie, bis der Test abgeschlossen ist. Die Ergebnisse werden in `/workspace/results/` gespeichert.

9) Führen Sie den zweiten Benchmark-Test mit **180 Benutzern pro Sekunde** durch:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm --ramp-up 5 --users-per-sec=180 --measurement=60
    ```

10) Führen Sie den dritten Benchmark-Test mit **200 Benutzern pro Sekunde** durch:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm --ramp-up 5 --users-per-sec=200 --measurement=60
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

## Teil 2: Optimiertes Keycloak benchmarken

Jetzt wenden Sie Ihr Wissen aus dem "optimized"-Lab an und testen, ob die Optimierungen die Performance verbessern.

14) Stoppen Sie die laufenden Container:
    ```bash
    docker compose down
    ```

15) Erstellen Sie eine neue Datei `docker-compose-optimized.yml` im Lab-Verzeichnis mit folgender Konfiguration:
    - PostgreSQL-Datenbank (wie im optimized-Lab)
    - Ihr optimiertes Keycloak-Image aus dem optimized-Lab
    - VS Code Web Container (für die Benchmark-Ausführung)

    **Hinweise:**
    - Verwenden Sie das Image `my-own-keycloak`, das Sie im optimized-Lab gebaut haben
    - Konfigurieren Sie Keycloak mit PostgreSQL
    - Stellen Sie sicher, dass die VS Code-Umgebung Zugriff auf die Scripts hat
    - Verwenden Sie die gleichen Ports wie zuvor

16) Bauen Sie zunächst das optimierte Image (falls noch nicht geschehen):
    ```bash
    cd ../lab-optimized
    docker build -t my-own-keycloak .
    cd ../lab-benchmarking
    ```

17) Starten Sie die neue optimierte Umgebung:
    ```bash
    docker compose -f docker-compose-optimized.yml up
    ```

18) Wiederholen Sie die Schritte 4-13 mit der optimierten Keycloak-Instanz.

19) Vergleichen Sie die Ergebnisse:

    **Fragen zur Analyse:**
    - Wie unterscheiden sich die P95/P99-Latenzzeiten zwischen dev-Mode und optimiertem Keycloak?
    - Bei welcher Last beginnt das optimierte Keycloak zu kämpfen (verglichen mit dem dev-Mode)?
    - Welche konkreten Performance-Verbesserungen können Sie messen?
    - Rechtfertigen die Verbesserungen den zusätzlichen Aufwand der Optimierung?

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

5) Create a realm that can be used for benchmarking:
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
   ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm --ramp-up 5 --users-per-sec=150 --measurement=60
   ```

   This test simulates 150 users per second logging in via OAuth2 Authorization Code Flow (60 seconds measurement).

8) Wait until the test completes. Results are saved to `/workspace/results/`.

9) Run the second benchmark test with **180 users per second**:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm --ramp-up 5  --users-per-sec=180 --measurement=60
    ```

10) Run the third benchmark test with **200 users per second**:
    ```bash
    ./kcb.sh --scenario=keycloak.scenario.authentication.AuthorizationCode --server-url=http://keycloak:8080 --realm-name=benchmark-realm --ramp-up 5  --users-per-sec=200 --measurement=60
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

---

## Part 2: Benchmarking Optimized Keycloak

Now apply your knowledge from the "optimized" lab and test whether the optimizations improve performance.

14) Stop the running containers:
    ```bash
    docker compose down
    ```

15) Create a new file `docker-compose-optimized.yml` in the lab directory with the following configuration:
    - PostgreSQL database (like in the optimized lab)
    - Your optimized Keycloak image from the optimized lab
    - VS Code Web container (for running benchmarks)

    **Hints:**
    - Use the image `my-own-keycloak` that you built in the optimized lab
    - Configure Keycloak with PostgreSQL
    - Ensure the VS Code environment has access to the scripts
    - Use the same ports as before

16) First, build the optimized image (if not already done):
    ```bash
    cd ../lab-optimized
    docker build -t my-own-keycloak .
    cd ../lab-benchmarking
    ```

17) Start the new optimized environment:
    ```bash
    docker compose -f docker-compose-optimized.yml up
    ```

18) Repeat steps 4-13 with the optimized Keycloak instance.

19) Compare the results:

    **Analysis Questions:**
    - How do P95/P99 latencies differ between dev-mode and optimized Keycloak?
    - At what load level does the optimized Keycloak start to struggle (compared to dev-mode)?
    - What specific performance improvements can you measure?
    - Do the improvements justify the additional effort of optimization?
