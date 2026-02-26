# Lab Monitoring

## DE

Ziel: Keycloak-Metriken mit Prometheus und Grafana erfassen und visualisieren.

### Aufbau

Die `docker-compose.yaml` startet drei Services:

| Service              | URL                        | Zugangsdaten    |
|----------------------|----------------------------|-----------------|
| Keycloak (Admin UI)  | http://localhost:8080      | `admin`/`admin` |
| Keycloak (Metrics)   | http://localhost:9000      | -               |
| Prometheus           | http://localhost:9090      | -               |
| Grafana              | http://localhost:3000      | `admin`/`admin` |

Keycloak wird mit den Flags `--metrics-enabled=true` und `--health-enabled=true` gestartet.

**Wichtig:** Seit Keycloak 25 werden Metrics und Health auf einem **separaten Management-Port (9000)** bereitgestellt, nicht auf dem Haupt-Port 8080.

### Erster Teil: Metrics-Endpunkt erkunden

1) Wechselt auf der Kommandozeile in diesen Ordner und startet die Umgebung:
   ```bash
   docker compose up
   ```
2) Wartet, bis Keycloak vollständig gestartet ist (Log: `Listening on: http://0.0.0.0:8080`).
3) Ruft den Metrics-Endpunkt auf dem **Management-Port** auf: http://localhost:9000/metrics
4) Schaut euch die Ausgabe an. Ihr seht Metriken im Prometheus-Format. Sucht nach:
   - `jvm_memory_used_bytes` (JVM Speicherverbrauch)
   - `http_server_requests_seconds_count` (HTTP Request Counter)
   - `jvm_threads_live_threads` (Anzahl aktiver Threads)
5) Ruft die Health-Endpunkte auf:
   - http://localhost:9000/health/ready
   - http://localhost:9000/health/live

### Zweiter Teil: Prometheus Targets pruefen

1) Oeffnet die Prometheus-Oberflaeche: http://localhost:9090
2) Navigiert zu **Status -> Target Health**. Der Keycloak-Target sollte den Status `UP` haben.
3) Gebt im Query-Feld eine Metrik ein, z.B. `jvm_memory_used_bytes`, und klickt **Execute**. Wechselt auf den Tab **Graph**.
4) Probiert weitere PromQL-Queries aus:
   - `rate(http_server_requests_seconds_count[1m])` (HTTP Requests pro Sekunde)
   - `jvm_threads_live_threads` (Aktive Threads)
   - `process_uptime_seconds` (Uptime in Sekunden)

### Dritter Teil: Grafana Dashboard

1) Oeffnet Grafana: http://localhost:3000 (Login: `admin`/`admin`, Skip bei Passwort-Aenderung).
2) Navigiert zu **Dashboards**. Das Dashboard **Keycloak Monitoring** ist bereits vorkonfiguriert.
3) Oeffnet das Dashboard. Ihr seht Panels zu:
   - JVM Memory und Threads
   - HTTP Request Rate und Latenz (p95)
   - Keycloak Login Events (Logins, Fehler, Registrierungen)
   - DB Connection Pool
   - CPU Usage, Uptime, GC Pausen

### Vierter Teil: Last erzeugen und Metriken beobachten

1) Legt in der Admin Console (http://localhost:8080/admin/) einen neuen Realm `lab-realm` an.
2) Legt im Realm `lab-realm` einen Benutzer an:
   - Username: `testuser`
   - Email Verified: On
   - Unter **Credentials**: Passwort setzen, Temporary: Off
3) Loggt euch mit dem Benutzer `testuser` mehrfach in die Account Console ein und wieder aus:
   http://localhost:8080/realms/lab-realm/account/
4) Beobachtet im Grafana-Dashboard die Panels **Keycloak Login Events** und **HTTP Server Requests** - die Werte sollten ansteigen.
5) Versucht auch fehlerhafte Logins (falsches Passwort) und beobachtet die Login-Error-Metrik.

---

## EN

Goal: Collect and visualize Keycloak metrics using Prometheus and Grafana.

### Setup

The `docker-compose.yaml` starts three services:

| Service            | URL                        | Credentials     |
|--------------------|----------------------------|-----------------|
| Keycloak (Admin UI)| http://localhost:8080      | `admin`/`admin` |
| Keycloak (Metrics) | http://localhost:9000      | -               |
| Prometheus         | http://localhost:9090      | -               |
| Grafana            | http://localhost:3000      | `admin`/`admin` |

Keycloak is started with the flags `--metrics-enabled=true` and `--health-enabled=true`.

**Important:** Since Keycloak 25, metrics and health are served on a **separate management port (9000)**, not on the main port 8080.

### Part 1: Explore the Metrics Endpoint

1) Open a terminal in this directory and start the environment:
   ```bash
   docker compose up
   ```
2) Wait until Keycloak is fully started (log: `Listening on: http://0.0.0.0:8080`).
3) Open the metrics endpoint on the **management port**: http://localhost:9000/metrics
4) Examine the output. You will see metrics in Prometheus format. Look for:
   - `jvm_memory_used_bytes` (JVM memory usage)
   - `http_server_requests_seconds_count` (HTTP request counter)
   - `jvm_threads_live_threads` (number of active threads)
5) Check the health endpoints:
   - http://localhost:9000/health/ready
   - http://localhost:9000/health/live

### Part 2: Verify Prometheus Targets

1) Open the Prometheus UI: http://localhost:9090
2) Navigate to **Status -> Targets**. The Keycloak target should show status `UP`.
3) Enter a metric in the query field, e.g. `jvm_memory_used_bytes`, and click **Execute**. Switch to the **Graph** tab.
4) Try additional PromQL queries:
   - `rate(http_server_requests_seconds_count[1m])` (HTTP requests per second)
   - `jvm_threads_live_threads` (active threads)
   - `process_uptime_seconds` (uptime in seconds)

### Part 3: Grafana Dashboard

1) Open Grafana: http://localhost:3000 (login: `admin`/`admin`, skip password change).
2) Navigate to **Dashboards**. The **Keycloak Monitoring** dashboard is already pre-configured.
3) Open the dashboard. You will see panels for:
   - JVM memory and threads
   - HTTP request rate and latency (p95)
   - Keycloak login events (logins, errors, registrations)
   - DB connection pool
   - CPU usage, uptime, GC pauses

### Part 4: Generate Load and Observe Metrics

1) In the Admin Console (http://localhost:8080/admin/), create a new realm `lab-realm`.
2) In the `lab-realm`, create a user:
   - Username: `testuser`
   - Email Verified: On
   - Under **Credentials**: set a password, Temporary: Off
3) Log in and out multiple times with `testuser` via the Account Console:
   http://localhost:8080/realms/lab-realm/account/
4) Watch the **Keycloak Login Events** and **HTTP Server Requests** panels in Grafana - values should increase.
5) Also try failed logins (wrong password) and observe the login error metric.
