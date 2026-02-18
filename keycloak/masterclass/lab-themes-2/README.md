# Lab Keycloak Themes 2

## DE

1) Prüft die `docker-compose.yaml` auf Änderungen und versucht zu verstehen, was diese machen.
2) Startet das Lab via `docker compose up`.
3) Legt einen Realm an und setzt in den Realm Settings das Login-Theme auf `acme-theme`.
4) Schaut euch den `themes`-Ordner an und versteht seine Struktur sowie die `theme.properties`-Datei.
5) Schaut euch die `login.ftl` an – das ist das FreeMarker-Template, das die komplette Login-Seite rendert. Hier habt ihr volle Kontrolle über HTML, CSS und JavaScript.
6) Nehmt eine kleine Änderung (z. B. eine Farbe in den CSS-Variablen oder ein Text in der `login.ftl`) vor und prüft die Auswirkungen.
7) Sucht in der `login.ftl` den `TODO`-Kommentar. Fügt dort eine FreeMarker-`<#if>`-Anweisung ein, die einen **"⚠ Demo Environment"**-Hinweis anzeigt, wenn der Realm-Name `labrealm` ist. Schaut euch auch die anderen `<#if>`-Blöcke in der Datei an (z. B. `<#if message??>` oder `<#if realm.rememberMe>`) und versteht, wie Keycloak-Variablen in FreeMarker geprüft werden.
   ```ftl
   <#if realm.name == "labrealm">
     <div class="alert alert-warning">
       <span class="alert-icon">⚠</span>
       <span>${msg("acme.demoWarning")}</span>
     </div>
   </#if>
   ```
   Der Text kommt dabei aus den Übersetzungsdateien im `messages/`-Ordner – schaut euch `messages_de.properties` und `messages_zh-CN.properties` an und versteht, wie der `msg()`-Aufruf die passende Übersetzung lädt.
8) Legt einen zweiten Realm mit dem Namen `labrealm` an, weist ihm das `acme-theme` als Login-Theme zu und öffnet die Login-Seite. Prüft, ob der "Demo Environment"-Hinweis erscheint – und dass er bei einem Realm mit einem anderen Namen **nicht** angezeigt wird.
9) Aktiviert die Mehrsprachigkeit im Realm: **Realm Settings → Localization → Internationalization → On**. Fügt dort Deutsch (`de`) und Chinesisch Vereinfacht/Simplified Chinese (`zh-CN`) als unterstützte Sprachen hinzu. Öffnet danach die Login-Seite – der Sprachumschalter erscheint unterhalb des Formulars. Schaut euch an, wie die Texte (Tagline, Demo-Hinweis, Footer) aus den Dateien im `messages/`-Ordner übersetzt werden.

## EN

1) Check the `docker-compose.yaml` for changes and try to understand what they do.
2) Start the lab via `docker compose up`.
3) Create a realm and set the login theme to `acme-theme` in the realm settings.
4) Have a look at the `themes` folder and understand its structure as well as the `theme.properties` file.
5) Have a look at `login.ftl` – this is the FreeMarker template that renders the complete login page. This gives you full control over HTML, CSS and JavaScript.
6) Make a small change (e.g. a color in the CSS variables or a text in `login.ftl`) and check the effects.
7) Find the `TODO` comment in `login.ftl`. Add a FreeMarker `<#if>` statement there that shows a **"⚠ Demo Environment"** notice when the realm name is `labrealm`. Use `${msg("acme.demoWarning")}` for the text so the message is translated. Also have a look at the other `<#if>` blocks in the file (e.g. `<#if message??>` or `<#if realm.rememberMe>`) and understand how Keycloak variables are checked in FreeMarker.
   ```ftl
   <#if realm.name == "labrealm">
     <div class="alert alert-warning">
       <span class="alert-icon">⚠</span>
       <span>${msg("acme.demoWarning")}</span>
     </div>
   </#if>
   ```
   The text is loaded from the translation files in the `messages/` directory – have a look at `messages_de.properties` and `messages_zh-CN.properties` to see the translations.
8) Create a second realm named exactly `labrealm`, assign the `acme-theme` login theme to it and open the login page. Verify that the "Demo Environment" banner from step 7 appears – and that it does **not** appear in a realm with a different name.
9) Enable internationalization in the realm: **Realm Settings → Localization → Internationalization → On**. Add German (`de`) and Simplified Chinese (`zh-CN`) as supported locales. Open the login page – the language switcher now appears below the form. Switch languages and observe how the texts (tagline, demo notice, footer) are translated from the files in the `messages/` directory.

### Key Keycloak Context Variables available in `login.ftl`

| Variable | Description |
| --- | --- |
| `${url.loginAction}` | Form action URL for the POST request |
| `${url.resourcesPath}` | Base URL for theme resources (CSS, JS, images) |
| `${url.loginResetCredentialsUrl}` | URL for the "Forgot password" page |
| `${url.registrationUrl}` | URL for the registration page |
| `${login.username}` | Pre-filled username value |
| `${login.rememberMe}` | State of the "Remember me" checkbox |
| `${realm.displayName}` | Display name of the realm |
| `${realm.rememberMe}` | Whether the realm has "Remember me" enabled |
| `${realm.registrationAllowed}` | Whether the realm allows self-registration |
| `${realm.resetPasswordAllowed}` | Whether the realm allows password reset |
| `${message.type}` | Alert type: `error` / `warning` / `success` / `info` |
| `${message.summary}` | Alert message text |
| `${auth.selectedCredential}` | Currently selected credential ID |
