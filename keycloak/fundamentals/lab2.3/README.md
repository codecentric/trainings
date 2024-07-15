# Lab 2.3

1) Bitte öffnet die in diesem Verzeichnis liegende Datei `docker-compose.yaml`.
2) Schaut euch den Inhalt der Datei an und prüft, welche Eigenschaften der Umgebung ihr hier erfahren könnt. Prüft insbesondere auch den `openldap`-Container.
3) Legt einen neuen Realm an.
4) Legt im Bereich User Federation eine neue LDAP-Verbindung an. Nutzt die folgenden Einstellungen und lasst alles andere auf ihrem Default. Nutzt Abschnittweise auch die Möglichkeiten zum Testen eurer Einstellungen.
   * Vendor: `Other`
   * Connection URL: `ldap://openldap:1389/`
   * Bind DN: `cn=admin,dc=codecentric,dc=de`
   * Edit Mode: `READ_ONLY`
   * Users DN: `ou=users,dc=codecentric,dc=de`
5) Wechselt in die Ansicht Users und prüft, ob eure Benutzer aus dem LDAP importiert wurden. Beachtet, dass die Benutzer nicht direkt in der Liste gezeigt werden, sondern nur über die Suche gefunden werden können.
6) Versucht euch mit einem der importierten Benutzer in die Account-Console einzuloggen. Den Link zur Account-Console findet ihr unter Clients in der rechten Spalte als Home URL.