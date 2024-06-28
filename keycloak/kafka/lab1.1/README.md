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
            <li>Über die kafka-ui -> configs lässt sich die aktuelle Konfiguration überprüfen. Aber auch im `compose.yaml`-Logs lässt sich die Meldung "Successfully authenticated as ..." für den jeweiligen Broker finden.</li>
        </ol>
    </li>
</ol>


[//]: # (1. Ungesichertes Kafka Cluster)

[//]: # (    1. Inspizieren der docker-compose.yaml)

[//]: # (        1. Zookeeper)

[//]: # (        2. Kafka Cluster mit 2 Brokern)

[//]: # (        3. Kafka-UI für Monitoring)

[//]: # (    2. Hochfahren)

[//]: # (        1. `docker compose up`)

[//]: # (    3. Status der Kafka Broker in Kafka-UI prüfen)

[//]: # (        1. http://localhost:8082)

[//]: # (        2. Broker Detailansicht -> Configs -> TODO)

[//]: # (    4. Docker Compose stoppen)

[//]: # (        1. `docker compose stop`)

[//]: # (2. Keycloak Service konfigurieren)

[//]: # (    1. Einloggen: admin:admin)

[//]: # (    2. Realm erstellen: 'kafka-realm')

[//]: # (    3. Client erstellen: kafka-broker-1)

[//]: # (        1. Client authentication aktivieren)

[//]: # (        1. Service Account Roles aktivieren)

[//]: # (        2. ggf. Direct Access <-- TODO)

[//]: # (        3. Reiter -> Client Scope -> Kafka broker 1 dedicated)

[//]: # (        4. Add Mapper -> by Configuration -> Audience)

[//]: # (            1. Name -> TODO)

[//]: # (            2. Included Client Audience -> None)

[//]: # (            3. Included Custom Audience -> kafka-broker)

[//]: # (3. Kommunikation zwischen Brokern mit Keycloak absichern)

[//]: # (    1. Auskommentierte Zeilen der docker-compose.yaml einkommentieren)

[//]: # (    2. Fehlende Konfigurationen für die Kafka Services kafka1 und kafka2 ergänzen)

[//]: # (       --> TODO Formatierung)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_SASL_ENABLED_MECHANISMS: OAUTHBEARER)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_SASL_OAUTHBEARER_JWKS_ENDPOINT_URL: http://keycloak:8080/realms/kafka-realm/protocol/openid-connect/certs)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_SASL_OAUTHBEARER_EXPECTED_AUDIENCE: kafka-broker)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_SASL_OAUTHBEARER_EXPECTED_ISSUER: http://keycloak:8080/realms/kafka-realm)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_OAUTHBEARER_SASL_LOGIN_CALLBACK_HANDLER_CLASS: org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginCallbackHandler)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_SASL_OAUTHBEARER_TOKEN_ENDPOINT_URL: http://keycloak:8080/realms/kafka-realm/protocol/openid-connect/token)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_OAUTHBEARER_SASL_JAAS_CONFIG: org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required clientId="kafka-broker" clientSecret="0fpvI3td395EQeTzCjg1tLj6Xxtd5m21" scope="profile";)

[//]: # (       KAFKA_LISTENER_NAME_INTERBROKER_OAUTHBEARER_SASL_SERVER_CALLBACK_HANDLER_CLASS: org.apache.kafka.common.security.oauthbearer.OAuthBearerValidatorCallbackHandler)

[//]: # (       KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: OAUTHBEARER)