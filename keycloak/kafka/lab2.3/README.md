# Secure Kafka with Keycloak

## Lab 3: Secure Client Communication

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
    <li>Topic anlegen: `docker-compose exec -it kafka-admin-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --topic topic-a --create --partitions 1 --replication-factor 1 --command-config /etc/kafka/kafka-admin-cli.conf`</li>
</ol>