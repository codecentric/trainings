# Secure Kafka with Keycloak

## Lab 3: ACLs konfigurieren

**Übungsaufbau:** In der compose-file ist ein Kafka-Setup konfiguriert. 

**Ziel:** Wir konfigurieren einen Client "User-CLI", der Berechtigung für Topic A, aber nicht für Topic B besitzt. 


<u>Teil 1 - Setup aufbauen</u>

Trainer erklärt das compose-File!

<ol>
    <li>Starte das compose-File: `docker-compose up`</li>
    <li>Im Keycloak (http://localhost:8080):
    <ol>
        <li>Erstelle einen Realm `kafka`</li>    
        <li>Konfiguriere einen Client-Scope für die Audience</li>
        <li>Konfiguriere in Keycloak Clients für den kafka-broker, die Admin-CLI und die User-CLI</li>
        <li>Unter Configure/Realm settings: exportiere unter Action/partial export die Realm-Settings mit Clients</li>
    </ol>
    </li>
    <li>Konfiguriere die Client-Secrets für Admin-CLI und User-CLI in den zugehörenden conf-files</li>
    <li>Notiere dir die SUBs der beiden Clients Admin-CLI und User-CLI aus dem Realm-Sesstings-Export (stehen über der clientId)</li>
    <li>Trage die ID des AdminCLI-Clients als KAFKA_SUPER_USERS in das compose-File ein</li>
    <li>Starte das compose-file neu</li>
</ol>

<u>Teil 2 - ACL-Berechtigungen</u>
<ol>
    <li>Mit dem Admin-User Topic anlegen: `docker-compose exec -it kafka-admin-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --topic topic-a --create --partitions 1 --replication-factor 1 --command-config /etc/kafka/kafka-admin-cli.conf`</li>
    <li>Eine weitere Topic anlegen: topic-b</li>
    <li>Topics mit `docker-compose exec -it kafka-admin-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --list --command-config /etc/kafka/kafka-admin-cli.conf` prüfen.</li>
    <li>Als User die Topics anzeigen lassen: `docker-compose exec -it kafka-admin-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --list --command-config /etc/kafka/kafka-admin-cli.conf`</li>
    <li>Als User versuchen, eine Nachricht zu senden: docker-compose exec kafka-user-cli /bin/kafka-console-producer --broker-list kafka-broker:9092 --topic topic-a --producer.config /etc/kafka/kafka-user-cli.conf</li>
    <li>Wir müssen den User für die topic-a berechtigen: docker-compose exec kafka-admin-cli /bin/kafka-acls --bootstrap-server kafka-broker:9092 --add --allow-principal User:9b0289e1-645d-46fb-8461-728041b639f3 --operation ALL --topic topic-a --command-config /etc/kafka/kafka-admin-cli.conf</li>
    <li>Jetzt nochmal als User eine Nachricht versenden und im kafka-ui prüfen.</li>
    <li>In kafka-ui lassen sich auch die ACLs anzeigen.</li>
</ol>