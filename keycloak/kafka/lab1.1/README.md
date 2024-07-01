# Secure Kafka with Keycloak

## Lab 1: Secure Interbroaker Communication

### Teil 1: Cluster mit ungesicherter Interbroker-Kommunikation

**Übungsaufbau:** In der compose-file ist ein Kafka-Cluster mit 2 Brokern, eine Zookeeper-Instanz, eine Keycloak-Instanz und eine kafka-ui-Instanz zur Visualisierung konfiguriert. 

**Ziel:** Die beiden Kafka-Broker sollen in der internen Kommunikation mit dem "SASL OAuth Bearer"-Mechanismus abgesichert werden. 

<u>Teil 1 - Ungesicherte Interbroker-Kommunikation</u>

<ol>
    <li>Schaue dir die `compose.yaml` an, die zu nächst nicht relevanten Teile sind auskommentiert.</li>
    <li>Starte das compose-File: `docker-compuse up`</li>
    <li>Wenn alle Komponenten hochgefahren sind, schauen wir uns das Kafka-Cluster in der kafka-ui an: http://localhost:8082
        <ol>
            <li>Unter Brokers sind beide Broker online</li>
            <li>Unter Broker-Details/Confics nach dem Begriff 'security' suchen</li>
            <li>Der Key 'security.inter.broker.protocol' gibt Auskunft über das konfigurierte Protokoll</li>
        </ol>
    </li>
</ol>


<u>Teil 2 - Interbroker-Kommunikation mit Keycloak absichern</u>
<ol>
    <li>Zunächst müssen beide Kafka-Broker als Clients in Keycloak konfiguriert werden: http://localhost:8080
        <ol>
            <li>Wir konfigurieren alle Apps in einem eigenen Realm (z.B. 'kafka')</li>
            <li>Erstelle für jeden Kafka-Broker einen eigenen Client (kafka-broker-1 & kafka-broker-2)
            <li>Die Clients sind vom Typ <i>confidential access type</i></li> und mit dem Authentication flow <i>Client Credentials Grant</i>
            <li>Kafka limitiert die Token mit einer <u>Audience</u> (https://www.keycloak.org/docs/latest/server_admin/#audience-support). Erstelle einen Scope mit einem Audience-Mapper. Wir konfigurieren die Audience 'kafka-broker' hardcoded. Hinweis: Achte darauf, der der erstellte Client Scope zum Client hinzugefügt wird!</li>
            <li>Das `compose.yaml` anpassen: Ändere die `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP` für den INTERBROKER auf `SASL`PLAINTEXT` und setze die Client-Secrets für die jeweiligen kafla-clients.</li>
            <li>Das `compose.yaml` neu starten.</li>
            <li>Über die kafka-ui -> configs lässt sich die aktuelle Konfiguration überprüfen: Was fällt dir beim interbroker protocol auf?</li>
            <li>Aber auch im `compose.yaml`-Logs lässt sich die Meldung "Successfully authenticated as ..." für den jeweiligen Broker finden.</li>
        </ol>
    </li>
</ol>
