# Lab Logging

## DE

Ziel: Keycloak-Logging konfigurieren und Logs zentral mit Loki und Grafana durchsuchen.

### Aufbau

Die `docker-compose.yaml` startet vier Services:

| Service    | URL                   | Zugangsdaten    | Aufgabe                          |
|------------|-----------------------|-----------------|----------------------------------|
| Keycloak   | http://localhost:8080 | `admin`/`admin` | IAM-Server mit konfigurierbarem Logging |
| Loki       | http://localhost:3100 | -               | Log-Aggregation ("Prometheus fuer Logs") |
| Promtail   | -                     | -               | Sammelt Container-Logs, schickt sie an Loki |
| Grafana    | http://localhost:3000 | `admin`/`admin` | Log-Visualisierung und LogQL-Queries |

### Erster Teil: Keycloak Standard-Logging

1) Wechselt auf der Kommandozeile in diesen Ordner und startet die Umgebung:
   ```bash
   docker compose up
   ```
2) Wartet, bis Keycloak gestartet ist und schaut euch die Log-Ausgabe im Terminal an. Das Standard-Format ist:
   ```
   2026-02-25 10:00:00,000 INFO  [org.keycloak.services] KC-SERVICES0050: Initializing master realm
   ```
3) Oeffnet die `docker-compose.yaml` und schaut euch die Log-Konfiguration an:
   - `KC_LOG`: Ausgabeziel (`console`, `file`, `syslog`)
   - `KC_LOG_CONSOLE_FORMAT`: Format der Console-Ausgabe
   - `KC_LOG_LEVEL`: Log-Level (Root und Kategorie-spezifisch)

### Zweiter Teil: JSON-Logging aktivieren

Strukturierte Logs im JSON-Format sind in der Praxis wichtig, weil sie maschinell auswertbar sind.

1) Stoppt die Umgebung mit `Ctrl+C`.
2) Aendert in der `docker-compose.yaml` das Log-Format auf JSON:
   ```yaml
   KC_LOG_CONSOLE_FORMAT: json
   ```
3) Startet die Umgebung neu: `docker compose up`
4) Vergleicht die Ausgabe - jede Log-Zeile ist jetzt ein JSON-Objekt:
   ```json
   {"timestamp":"2026-02-25T10:00:00.000Z","level":"INFO","loggerName":"org.keycloak.services","message":"KC-SERVICES0050: Initializing master realm"}
   ```
5) Welche Vorteile hat das JSON-Format gegenueber dem Text-Format?

### Dritter Teil: Log-Level anpassen

1) Aendert `KC_LOG_LEVEL` in der `docker-compose.yaml`, um Kategorie-spezifische Levels zu setzen:
   ```yaml
   KC_LOG_LEVEL: "INFO,org.keycloak.events:DEBUG"
   ```
   Das setzt den Root-Level auf `INFO`, aber die Event-Kategorie auf `DEBUG`.
2) Startet neu: `docker compose up`
3) Loggt euch in Keycloak ein und beobachtet die zusaetzlichen Debug-Meldungen fuer Events im Terminal.
4) Probiert weitere Kombinationen aus:
   - `KC_LOG_LEVEL: "WARN"` - nur Warnungen und Fehler
   - `KC_LOG_LEVEL: "INFO,org.keycloak.events:DEBUG,org.keycloak.authentication:TRACE"` - Events und Authentication sehr detailliert

### Vierter Teil: Logs in Grafana durchsuchen

1) Stellt sicher, dass `KC_LOG_CONSOLE_FORMAT: json` gesetzt ist und startet die Umgebung.
2) Legt einen Realm `lab-realm` und einen Benutzer an (Username: `testuser`, Email Verified: On, Passwort gesetzt, Temporary: Off).
3) Loggt euch mehrfach ein und aus: http://localhost:8080/realms/lab-realm/account/
4) Oeffnet Grafana: http://localhost:3000 (Login: `admin`/`admin`, Skip bei Passwort-Aenderung).
5) Navigiert zu **Explore** (Kompass-Icon links) und waehlt die Datasource **Loki**.
6) Fuehrt eure erste LogQL-Query aus:
   ```
   {service="keycloak"}
   ```
   Das zeigt alle Keycloak-Logs.

### Fuenfter Teil: LogQL-Queries

Probiert folgende Queries in Grafana Explore aus:

```logql
# Alle Keycloak-Logs
{service="keycloak"}

# Nur Fehler und Warnungen
{service="keycloak"} |= "ERROR" or {service="keycloak"} |= "WARN"

# Logs nach einem bestimmten Text filtern
{service="keycloak"} |= "LOGIN"

# Bei JSON-Format: nach Feldern filtern
{service="keycloak"} | json | level="ERROR"

# Bei JSON-Format: nach Logger-Kategorie filtern
{service="keycloak"} | json | loggerName="org.keycloak.events"

# Anzahl der Log-Zeilen pro Minute
rate({service="keycloak"}[1m])

# Anzahl der Fehler pro Minute
rate({service="keycloak"} | json | level="ERROR" [1m])
```

### Sechster Teil: Event-Logging aktivieren

1) Loggt euch in die Admin Console ein: http://localhost:8080/admin/
2) Wechselt in den Realm `lab-realm`.
3) Navigiert zu **Realm settings → Events**.
4) Unter **User events settings**: Schaltet **Save events** ein und klickt **Save**.
5) Unter **Admin events settings**: Schaltet **Save events** und **Include representation** ein und klickt **Save**.
6) Fuehrt einige Aktionen aus:
   - Loggt euch als `testuser` ein und aus (User Event)
   - Legt einen neuen Benutzer an (Admin Event)
   - Versucht einen fehlerhaften Login (User Event: LOGIN_ERROR)
7) Prueft die Events in der Admin Console unter **Events → User events** und **Events → Admin events**.
8) Sucht die Events in Grafana mit LogQL:
   ```logql
   {service="keycloak"} |= "LOGIN"
   ```

---

## EN

Goal: Configure Keycloak logging and search logs centrally using Loki and Grafana.

### Setup

The `docker-compose.yaml` starts four services:

| Service    | URL                   | Credentials     | Purpose                              |
|------------|-----------------------|-----------------|--------------------------------------|
| Keycloak   | http://localhost:8080 | `admin`/`admin` | IAM server with configurable logging |
| Loki       | http://localhost:3100 | -               | Log aggregation ("Prometheus for logs") |
| Promtail   | -                     | -               | Collects container logs, ships to Loki |
| Grafana    | http://localhost:3000 | `admin`/`admin` | Log visualization and LogQL queries  |

### Part 1: Keycloak Default Logging

1) Open a terminal in this directory and start the environment:
   ```bash
   docker compose up
   ```
2) Wait for Keycloak to start and observe the log output in the terminal. The default format is:
   ```
   2026-02-25 10:00:00,000 INFO  [org.keycloak.services] KC-SERVICES0050: Initializing master realm
   ```
3) Open `docker-compose.yaml` and review the log configuration:
   - `KC_LOG`: Output target (`console`, `file`, `syslog`)
   - `KC_LOG_CONSOLE_FORMAT`: Console output format
   - `KC_LOG_LEVEL`: Log level (root and category-specific)

### Part 2: Enable JSON Logging

Structured JSON logs are important in practice because they can be parsed by machines.

1) Stop the environment with `Ctrl+C`.
2) Change the log format to JSON in `docker-compose.yaml`:
   ```yaml
   KC_LOG_CONSOLE_FORMAT: json
   ```
3) Restart the environment: `docker compose up`
4) Compare the output - each log line is now a JSON object:
   ```json
   {"timestamp":"2026-02-25T10:00:00.000Z","level":"INFO","loggerName":"org.keycloak.services","message":"KC-SERVICES0050: Initializing master realm"}
   ```
5) What are the advantages of JSON format over plain text format?

### Part 3: Adjust Log Levels

1) Change `KC_LOG_LEVEL` in `docker-compose.yaml` to set category-specific levels:
   ```yaml
   KC_LOG_LEVEL: "INFO,org.keycloak.events:DEBUG"
   ```
   This sets the root level to `INFO` but the events category to `DEBUG`.
2) Restart: `docker compose up`
3) Log in to Keycloak and observe the additional debug messages for events in the terminal.
4) Try other combinations:
   - `KC_LOG_LEVEL: "WARN"` - only warnings and errors
   - `KC_LOG_LEVEL: "INFO,org.keycloak.events:DEBUG,org.keycloak.authentication:TRACE"` - events and authentication in detail

### Part 4: Search Logs in Grafana

1) Make sure `KC_LOG_CONSOLE_FORMAT: json` is set and start the environment.
2) Create a realm `lab-realm` and a user (username: `testuser`, email verified: on, password set, temporary: off).
3) Log in and out multiple times: http://localhost:8080/realms/lab-realm/account/
4) Open Grafana: http://localhost:3000 (login: `admin`/`admin`, skip password change).
5) Navigate to **Explore** (compass icon on the left) and select the **Loki** datasource.
6) Run your first LogQL query:
   ```
   {service="keycloak"}
   ```
   This shows all Keycloak logs.

### Part 5: LogQL Queries

Try the following queries in Grafana Explore:

```logql
# All Keycloak logs
{service="keycloak"}

# Only errors and warnings
{service="keycloak"} |= "ERROR" or {service="keycloak"} |= "WARN"

# Filter logs by specific text
{service="keycloak"} |= "LOGIN"

# With JSON format: filter by fields
{service="keycloak"} | json | level="ERROR"

# With JSON format: filter by logger category
{service="keycloak"} | json | loggerName="org.keycloak.events"

# Count log lines per minute
rate({service="keycloak"}[1m])

# Count errors per minute
rate({service="keycloak"} | json | level="ERROR" [1m])
```

### Part 6: Enable Event Logging

1) Log in to the Admin Console: http://localhost:8080/admin/
2) Switch to the `lab-realm`.
3) Navigate to **Realm settings → Events**.
4) Under **User events settings**: Enable **Save events** and click **Save**.
5) Under **Admin events settings**: Enable **Save events** and **Include representation**, then click **Save**.
6) Perform some actions:
   - Log in and out as `testuser` (user event)
   - Create a new user (admin event)
   - Try a failed login (user event: LOGIN_ERROR)
7) Check the events in the Admin Console under **Events → User events** and **Events → Admin events**.
8) Search for events in Grafana using LogQL:
   ```logql
   {service="keycloak"} |= "LOGIN"
   ```
