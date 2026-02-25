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
   - `KC_LOG_CONSOLE_OUTPUT`: Ausgabeformat (`default` oder `json`)
   - `KC_LOG_LEVEL`: Log-Level (Root und Kategorie-spezifisch)

### Zweiter Teil: JSON-Logging aktivieren

Strukturierte Logs im JSON-Format sind in der Praxis wichtig, weil sie maschinell auswertbar sind.

1) Stoppt die Umgebung mit `Ctrl+C`.
2) Aendert in der `docker-compose.yaml` das Log-Format auf JSON:
   ```yaml
   KC_LOG_CONSOLE_OUTPUT: json
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

1) Stellt sicher, dass `KC_LOG_CONSOLE_OUTPUT: json` gesetzt ist und startet die Umgebung.
   Der `keycloak-init` Service legt automatisch den Realm `lab-realm` und den Benutzer `testuser` (Passwort: `testuser`) an.
2) Loggt euch mehrfach mit `testuser` ein und aus: http://localhost:8080/realms/lab-realm/account/
3) Oeffnet Grafana: http://localhost:3000 (Login: `admin`/`admin`, Skip bei Passwort-Aenderung).
4) Navigiert zu **Explore** (Kompass-Icon links) und waehlt die Datasource **Loki**.
5) Fuehrt eure erste LogQL-Query aus:
   ```
   {service_name="/kc-mc-lab-logging-keycloak-1"}
   ```
   Das zeigt alle Keycloak-Logs.

### Fuenfter Teil: LogQL-Queries

Probiert folgende Queries in Grafana Explore aus:

```logql
# Alle Keycloak-Logs
{service_name="/kc-mc-lab-logging-keycloak-1"}

# Nur Fehler und Warnungen
{service_name="/kc-mc-lab-logging-keycloak-1"} |= "ERROR" or {service_name="/kc-mc-lab-logging-keycloak-1"} |= "WARN"

# Logs nach einem bestimmten Text filtern
{service_name="/kc-mc-lab-logging-keycloak-1"} |= "LOGIN"

# Bei JSON-Format: nach Feldern filtern
{service_name="/kc-mc-lab-logging-keycloak-1"} | json | level="ERROR"

# Bei JSON-Format: nach Logger-Kategorie filtern
{service_name="/kc-mc-lab-logging-keycloak-1"} | json | loggerName="org.keycloak.events"

# Anzahl der Log-Zeilen pro Minute
rate({service_name="/kc-mc-lab-logging-keycloak-1"}[1m])

# Anzahl der Fehler pro Minute
rate({service_name="/kc-mc-lab-logging-keycloak-1"} | json | level="ERROR" [1m])
```

### Sechster Teil: Aenderungen in Loki nachvollziehen

Ziel: Eine Benutzeraktion in der Account Console durchfuehren und den zugehoerigen Log-Eintrag in Loki finden.

1) Loggt euch als `testuser` in die Account Console ein: http://localhost:8080/realms/lab-realm/account/
2) Klickt auf **Personal info** und aendert den Benutzernamen (z.B. von `testuser` auf `testuser-renamed`).
3) Wechselt zu Grafana Explore und sucht den passenden Log-Eintrag:
   ```logql
   {service_name="/kc-mc-lab-logging-keycloak-1"} |= "UPDATE_PROFILE"
   ```
4) Untersucht den Log-Eintrag. Welche Informationen liefert Keycloak zu dieser Aktion?
5) Probiert weitere Aktionen und sucht die zugehoerigen Logs:
   - Passwort aendern → `UPDATE_PASSWORD`
   - Fehlerhafter Login → `LOGIN_ERROR`
   - Erfolgreicher Login → `LOGIN`

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
   - `KC_LOG_CONSOLE_OUTPUT`: Output format (`default` or `json`)
   - `KC_LOG_LEVEL`: Log level (root and category-specific)

### Part 2: Enable JSON Logging

Structured JSON logs are important in practice because they can be parsed by machines.

1) Stop the environment with `Ctrl+C`.
2) Change the log format to JSON in `docker-compose.yaml`:
   ```yaml
   KC_LOG_CONSOLE_OUTPUT: json
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

1) Make sure `KC_LOG_CONSOLE_OUTPUT: json` is set and start the environment.
   The `keycloak-init` service automatically creates the realm `lab-realm` and user `testuser` (password: `testuser`).
2) Log in and out multiple times as `testuser`: http://localhost:8080/realms/lab-realm/account/
3) Open Grafana: http://localhost:3000 (login: `admin`/`admin`, skip password change).
4) Navigate to **Explore** (compass icon on the left) and select the **Loki** datasource.
5) Run your first LogQL query:
   ```
   {service_name="/kc-mc-lab-logging-keycloak-1"}
   ```
   This shows all Keycloak logs.

### Part 5: LogQL Queries

Try the following queries in Grafana Explore:

```logql
# All Keycloak logs
{service_name="/kc-mc-lab-logging-keycloak-1"}

# Only errors and warnings
{service_name="/kc-mc-lab-logging-keycloak-1"} |= "ERROR" or {service_name="/kc-mc-lab-logging-keycloak-1"} |= "WARN"

# Filter logs by specific text
{service_name="/kc-mc-lab-logging-keycloak-1"} |= "LOGIN"

# With JSON format: filter by fields
{service_name="/kc-mc-lab-logging-keycloak-1"} | json | level="ERROR"

# With JSON format: filter by logger category
{service_name="/kc-mc-lab-logging-keycloak-1"} | json | loggerName="org.keycloak.events"

# Count log lines per minute
rate({service_name="/kc-mc-lab-logging-keycloak-1"}[1m])

# Count errors per minute
rate({service_name="/kc-mc-lab-logging-keycloak-1"} | json | level="ERROR" [1m])
```

### Part 6: Track Changes in Loki

Goal: Perform a user action in the Account Console and find the corresponding log entry in Loki.

1) Log in as `testuser` to the Account Console: http://localhost:8080/realms/lab-realm/account/
2) Click **Personal info** and change the username (e.g. from `testuser` to `testuser-renamed`).
3) Switch to Grafana Explore and search for the corresponding log entry:
   ```logql
   {service_name="/kc-mc-lab-logging-keycloak-1"} |= "UPDATE_PROFILE"
   ```
4) Examine the log entry. What information does Keycloak provide about this action?
5) Try more actions and search for their logs:
   - Change password → `UPDATE_PASSWORD`
   - Failed login → `LOGIN_ERROR`
   - Successful login → `LOGIN`
