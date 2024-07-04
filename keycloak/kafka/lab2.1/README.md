# Secure Kafka with Keycloak

## Lab 1: Secure Client Communication

**Übungsaufbau:** In der `compose`-file ist ein Kafka-Cluster mit 2 Brokern, eine Zookeeper-Instanz, eine Keycloak-Instanz und eine Kafka-UI-Instanz zur Visualisierung konfiguriert.

**Ziel:** Die beiden Kafka-Broker sollen in der internen Kommunikation mit dem "SASL OAuth Bearer"-Mechanismus abgesichert werden.

<u>Teil 1 - Ungesicherte Interbroker-Kommunikation</u>

<ol>
    <li>Schaue dir die <code>compose.yaml</code> an.</li>
    <li>Starte das compose-File: <code>docker-compuse up</code></li>
    <li>Wenn alle Komponenten hochgefahren sind, schauen wir uns das Kafka-Cluster in der Kafka-UI an: <a href="http://localhost:8082" target="_blank">http://localhost:8082</a>
        <ol>
            <li>Unter Brokers sind beide Broker online</li>
            <li>Unter Broker-Details/Configs nach dem Begriff <i>security</i> suchen</li>
            <li>Der Key <code>security.inter.broker.protocol</code> gibt Auskunft über das konfigurierte Protokoll</li>
        </ol>
    </li>
</ol>


<u>Teil 2 - Interbroker-Kommunikation mit Keycloak absichern</u>
<ol>
    <li>Zunächst müssen beide Kafka-Broker als Clients in Keycloak konfiguriert werden: <a href="http://localhost:8080" target="_blank">http://localhost:8080</a>
        <ol>
            <li>Wir konfigurieren alle Apps in einem eigenen Realm (z.B. <code>kafka</code>)</li>
            <li>Erstelle für jeden Kafka-Broker einen eigenen Client (<code>kafka-broker-1</code> & <code>kafka-broker-2</code>)</li>
            <li>Die Clients sind vom Typ <i>confidential access type</i> und mit dem Authentication flow <i>Client Credentials Grant</i>
            <li>Kafka limitiert die Token mit einer <u>Audience</u> (https://www.keycloak.org/docs/latest/server_admin/#audience-support). Erstelle einen Scope mit einem Audience-Mapper. Wir konfigurieren die Audience 'kafka-broker' hardcoded. Hinweis: Achte darauf, der der erstellte Client Scope zum Client hinzugefügt wird!</li>
            <li>Das <code>compose.yaml</code> anpassen: Ändere die <code>KAFKA_LISTENER_SECURITY_PROTOCOL_MAP</code> für den <code>INTERBROKER</code> auf <code>SASL_PLAINTEXT</code> und setze die Client-Secrets für die jeweiligen Kafka-Clients.</li>
            <li>Das <code>compose.yaml</code> neu starten.</li>
            <li>Über Kafka-UI -> Configs lässt sich die aktuelle Konfiguration überprüfen: Was fällt dir beim Protokoll <code>INTERBROKER</code> auf?</li>
            <li>Aber auch im <code>compose.yaml</code>-Logs lässt sich die Meldung <code>Successfully authenticated as ...</code> für den jeweiligen Broker finden.</li>
        </ol>
    </li>
</ol>
