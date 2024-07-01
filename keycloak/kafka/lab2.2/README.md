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
    <li>Versuche erneut eine Nachricht zu senden...</li>
    <li>Klappt natürlich nicht, konfiguriere den CLI-Client in der kafka-cli.conf</li>
    <li>Sende eine Nachricht mit der CLI-Konfiguration: `docker-compose exec kafka-cli /bin/kafka-console-producer --broker-list kafka-broker:9092 --topic topic1 --producer.config /etc/kafka/kafka-cli.conf`</li>
    <li>Empfange die Nachrichten mit der CLI-Konfiguration: `docker-compose exec -it kafka-cli /bin/kafka-console-consumer --bootstrap-server kafka-broker:9092 --topic topic1 --from-beginning --consumer.config /etc/kafka/kafka-cli.conf`</li>
    <li>Nutze auch gerne die Kafka-UI</li>
    <li>Frage: Warum werden für den Kafka-Broker keine Client-Credentials konfiguriert?</li>
</ol>