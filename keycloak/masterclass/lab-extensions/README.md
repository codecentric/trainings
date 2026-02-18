# Lab X.Y

## DE

1) Starten Sie die webbasierte Entwicklungsumgebung im `vscode`-Verzeichnis mit `docker compose up`.
2) Öffnen Sie die Entwicklungsumgebung im Browser unter `http://localhost:3000`.
3) Öffnen Sie in der Entwicklungsumgebung den Ordner **„workspace“**.
4) Im Ordner „workspace“ finden Sie ein typisches Keycloak-Extension-Projekt, basierend auf **Java** und **Maven**.
5) Implementieren Sie die Klassen `CustomEventListenerProviderFactory` und `CustomEventListenerProvider`.  
   Der `CustomEventListenerProvider` soll alle von Keycloak erzeugten Events entgegennehmen und protokollieren (z. B. über Logging).
6) Navigieren Sie zu `src/main/resources/META-INF/services` und fügen Sie den Fully Qualified Name (FQN) Ihrer `CustomEventListenerProviderFactory` in die bestehende Datei ein.  
   Der FQN besteht aus *Package-Name + Klassenname*.  
   Dies ist erforderlich, damit Keycloak Ihre `ProviderFactory` über den Service-Loader-Mechanismus erkennen und laden kann.
7) Bauen Sie das Projekt mit `mvn package`.
8) Starten Sie Keycloak aus dem Hauptverzeichnis des Projekts mit `docker compose up`.  
   Die gebaute Extension wird automatisch in das entsprechende Verzeichnis des Keycloak-Containers gemountet und beim Start geladen.
9) Interagieren Sie mit der Keycloak-UI (z. B. Login, Logout oder Benutzerverwaltung).  
   Prüfen Sie anschließend die Container-Logs: Werden die erzeugten Events von Ihrer Extension protokolliert?

## EN

1) Start the web-based development environment from the `vscode` directory using `docker compose up`.
2) Open the development environment in your browser at `http://localhost:3000`.
3) In the development environment, open the **“workspace”** folder.
4) Inside the “workspace” folder, you will find a typical Keycloak extension project based on **Java** and **Maven**.
5) Implement the classes `CustomEventListenerProviderFactory` and `CustomEventListenerProvider`.  
   The `CustomEventListenerProvider` should receive and log all events emitted by Keycloak (e.g., via logging).
6) Navigate to `src/main/resources/META-INF/services` and add the Fully Qualified Name (FQN) of your `CustomEventListenerProviderFactory` to the existing file.  
   The FQN consists of *package name + class name*.  
   This is required so that Keycloak can discover and load your `ProviderFactory` via the Service Loader mechanism.
7) Build the project using `mvn package`.
8) Start Keycloak from the project’s root directory using `docker compose up`.  
   The built extension will automatically be mounted into the appropriate directory of the Keycloak container and loaded on startup.
9) Interact with the Keycloak UI (e.g., login, logout, or user management actions).  
   Then check the container logs: Are the generated events being logged by your extension?
