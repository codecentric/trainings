# Lab 2.3

## DE

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

## EN

1) Please open the file `docker-compose.yaml` located in this directory.
2) Look at the contents of the file and check which properties of the environment you can find out here. In particular, check the `openldap` container.
3) Create a new realm.
4) Create a new LDAP connection in the User Federation area. Use the following settings and leave everything else at its default. Also use the options for testing your settings section by section.
   * Vendor: `Other`
   * Connection URL: `ldap://openldap:1389/`
   * Bind DN: `cn=admin,dc=codecentric,dc=de`
   * Edit Mode: `READ_ONLY`
   * Users DN: `ou=users,dc=codecentric,dc=de`
5) Switch to the Users view and check whether your users have been imported from the LDAP. Note that the users are not shown directly in the list, but can only be found via the search.
6) Try to log in to the Account Console with one of the imported users. You can find the link to the Account Console under Clients in the right-hand column as the Home URL.