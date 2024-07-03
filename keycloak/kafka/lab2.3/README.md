# Secure Kafka with Keycloak

## Lab 3: ACLs konfigurieren

**Übungsaufbau:** In der `compose`-file ist ein Kafka-Setup konfiguriert. Es gibt zudem zwei Clients, einen Admin und einen User.

**Ziel:** Wir konfigurieren einen Client "User-CLI", der Berechtigung für Topic A, aber nicht für Topic B besitzt. 


<u>Teil 1 - Setup aufbauen</u>

Trainer erklärt das compose-File!

<ol>
    <li>Starte das compose-File: <code>docker-compose up</code></li>
    <li>Im Keycloak (<a href="http://localhost:8080">http://localhost:8080</a>):
    <ol>
        <li>Erstelle einen Realm <code>kafka</code></li>    
        <li>Konfiguriere einen Client-Scope für die Audience <code>kafka-broker</code></li>
        <li>Konfiguriere in Keycloak Clients für den die <code>kafka-admin-cli</code> und die <code>kafka-user-cli</code></li>
        <li>Wir benötigen die User-IDs beider cli-clients, da sie als Identität auf das Principal gemappt werden. Zwei Möglichkeiten:
            <ol>
                <li>Unter Configure/Realm settings: Exportiere unter "Action/partial export" die Realm-Settings mit <u>Clients</u>. Zu den usernames <code>service-account-kafka-admin-cli</code> und <code>service-account-kafka-user-cli</code> steht auch die ID.</li>
                <li>Oder generiere dir mit den Client-Credentials einen Access-Token. Im sub-claim findest du die User-ID.</li>
            </ol>
        </li>
    </ol>
    </li>
    <li>Konfiguriere die Client-Secrets für <code>kafka-admin-cli</code> und <code>kafka-user-cli</code> in den zu gehörigen conf-files</li>
    <li>Trage die User-ID des <code>kafka-admin-cli</code> als KAFKA_SUPER_USERS in das compose-file ein</li>
    <li>Starte das compose-file neu</li>
</ol>

<u>Teil 2 - ACL-Berechtigungen</u>
<ol>
    <li>Mit dem Admin-User eine Topic <code>topic-a</code> anlegen: <pre><code>docker-compose exec -it kafka-admin-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --topic topic-a --create --partitions 1 --replication-factor 1 --command-config /etc/kafka/kafka-admin-cli.conf</code></pre></li>
    <li>Eine weitere Topic anlegen: <code>topic-b</code></li>
    <li>Topics mit <pre><code>docker-compose exec -it kafka-admin-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --list --command-config /etc/kafka/kafka-admin-cli.conf` anzeigen lassen</code></pre></li>
    <li>Als User die Topics anzeigen lassen: <pre><code>docker-compose exec -it kafka-user-cli /bin/kafka-topics --bootstrap-server kafka-broker:9092 --list --command-config /etc/kafka/kafka-user-cli.conf</code></pre></li>
    <li>Als User versuchen, eine Nachricht zu senden: <pre><code>docker-compose exec kafka-user-cli /bin/kafka-console-producer --broker-list kafka-broker:9092 --topic topic-a --producer.config /etc/kafka/kafka-user-cli.conf</code></pre></li>
    <li>Wir müssen den User für die topic-a berechtigen: <pre><code>docker-compose exec kafka-admin-cli /bin/kafka-acls --bootstrap-server kafka-broker:9092 --add --allow-principal User:user-id --operation ALL --topic topic-a --command-config /etc/kafka/kafka-admin-cli.conf</code></pre></li>
    <li>Jetzt nochmal als User eine Nachricht versenden und in der <a href="http://localhost:8082">kafka-ui</a> prüfen.</li>
    <li>In der <a href="http://localhost:8082">kafka-ui</a> lassen sich auch die ACLs anzeigen.</li>
</ol>