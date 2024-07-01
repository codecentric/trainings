# Secure Kafka with Keycloak

## Lab 2: Secure Client Communication

**Übungsaufbau:** In der compose-file ist ein Kafka-Setup konfiguriert. 

**Ziel:** Die Kafka-Client-Kommunikation soll über einen dedizierten Endpunkt mit dem "SASL OAuth Bearer"-Mechanismus abgesichert werden. 

<u>Teil 1 - Ungesicherte Kommunikation (Demo Trainer)</u>

<ol>
    <li>Schaue dir die `compose.yaml` an.</li>
    <li>Starte das compose-File: `docker-compuse up`</li>
    <li>Wenn alle Komponenten hochgefahren sind, schauen wir uns das Kafka-Cluster in der kafka-ui an: http://localhost:8082
        <ol>
            <li>Ein Broker ist online</li>
            <li>Es gibt keine Topic, Messages oder Consumer.</li>
        </ol>
    </li>
    <li>Lege eine Topic an: `docker-compose exec -it kafka-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --topic topic1 --create --partitions 1 --replication-factor 1`</li>
    <li>Produce eine Message auf der neuen Topic: `docker-compose exec kafka-cli /bin/kafka-console-producer --broker-list kafka-broker:9092 --topic topic1`</li>
    <li>Consume die Message von der Topic: `docker-compose exec -it kafka-cli /bin/kafka-console-consumer --bootstrap-server kafka-broker:9092 --topic topic1  --from-beginning`</li>
    <li>Zustand in der kafka-ui anschauen: http://localhost:8082
</ol>


<u>Teil 2 - Kafka-Client-Kommunikation mit Kafka absichern</u>
<ol>
    <li>Zuerst müssen die Clients in Keycloak konfiguriert werden: http://localhost:8080
        <ol>
            <li>Wir konfigurieren alle Apps in einem eigenen Realm (z.B. 'kafka')</li>            
            <li>Erstelle einen Client Scope mit einem default Audience-Mapper mit der Audience 'kafka-lab'</li>            
            <li>Erstelle für den Kafka-Broker einen Client 'kafka-broker' mit <i>confidential access type</i> und mit dem Authentication flow <i>Client Credentials Grant</i></li>
            <li>Erstelle für den Kafka-CLI-Client einen Client 'kafka-cli-client' mit <i>confidential access type</i> und mit dem Authentication flow <i>Client Credentials Grant</i></li>
        </ol>            
    </li>
    <li>Ändere den Listener PUBLIC auf SASL und starte das compose-file neu.</li>
    <ol>
            <li>Versuche erneut eine Nachricht zu senden, </li>            
            
    </ol>
</ol>
            <li>Kafka limitiert die Token mit einer <u>Audience</u> (https://www.keycloak.org/docs/latest/server_admin/#audience-support). Erstelle einen Scope mit einem Audience-Mapper. Wir konfigurieren die Audience 'kafka-broker' hardcoded. Hinweis: Achte darauf, der der erstellte Client Scope zum Client hinzugefügt wird!</li>
            <li>Das `compose.yaml` anpassen: Ändere die `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP` für den INTERBROKER auf `SASL`PLAINTEXT` und setze die Client-Secrets für die jeweiligen kafla-clients.</li>
            <li>Das `compose.yaml` neu starten.</li>
            <li>Über die kafka-ui -> configs lässt sich die aktuelle Konfiguration überprüfen: Was fällt dir beim interbroker protocol auf?</li>
            <li>Aber auch im `compose.yaml`-Logs lässt sich die Meldung "Successfully authenticated as ..." für den jeweiligen Broker finden.</li>
        </ol>
    </li>
    <li>Frage: Warum werden für den Kafka-Broker keine Client-Credentials konfiguriert?</li>




`docker-compose exec -it kafka-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --topic topic3 --create --partitions 1 --replication-factor 1`
`docker-compose exec kafka-cli /bin/kafka-console-producer --broker-list kafka-broker:9092 --topic topic1`
`docker-compose exec -it kafka-cli /bin/kafka-console-consumer --bootstrap-server kafka-broker:9092 --topic topic1  --from-beginning`


