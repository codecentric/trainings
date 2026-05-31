# Lab User Self-Service

## DE

Ziel: Ihr lernt, wie Benutzer in Keycloak eigenständig einen zweiten Faktor (TOTP) einrichten, wie der Admin zusätzlich Recovery Codes als Fallback aktiviert und wie der Benutzer sich bei Verlust des TOTP-Geräts mit einem Recovery Code anmelden kann.

### Setup

1) Wechselt auf der Kommandozeile in diesen Ordner und führt `docker compose up` aus. Wartet, bis im Log `Imported realm lab-realm` erscheint — der Realm `lab-realm` mit dem Benutzer `labuser` wurde damit automatisch importiert.
2) Loggt euch als Admin auf http://localhost:8080 mit `admin` / `admin` ein und wechselt in den Realm `lab-realm`.

### Teil 1: TOTP-Einrichtung beim 1. Login (User-Perspektive)

Der Benutzer `labuser` hat die Required Action `Configure OTP` bereits vorgesetzt — beim ersten Login zwingt Keycloak ihn also zur Einrichtung eines TOTP-Authenticators.

1) Öffnet ein privates Browserfenster (damit ihr parallel als Admin eingeloggt bleibt) und ruft die Account Console auf: http://localhost:8080/realms/lab-realm/account/
2) Loggt euch ein mit `labuser` / `labuser`.
3) Keycloak zeigt einen QR-Code an. Scannt diesen mit einer Authenticator-App eurer Wahl (Google Authenticator, FreeOTP, 1Password, Bitwarden, …) und bestätigt den 6-stelligen Code.
4) Loggt euch aus und erneut ein — diesmal werdet ihr nach Passwort **und** dem TOTP-Code gefragt.

### Teil 2: Recovery Codes aktivieren (Admin-Perspektive)

Hintergrund: In Keycloak 26.6.2 ist die Required Action `Recovery Authentication Codes` bereits aktiviert, und der `Recovery Authentication Code Form`-Step ist im Standard-Browser-Flow bereits vorhanden — allerdings **disabled**. Ohne ihn zu aktivieren kann der Benutzer die Codes zwar erzeugen, beim Login aber nicht statt seines TOTP-Codes nutzen — und genau das wollen wir für das Recovery-Szenario in Teil 4.

1) Wechselt im Admin in den Realm `lab-realm`, dann nach **Authentication → Flows → browser**. Klickt rechts oben auf **Duplicate** und vergebt einen Namen, z. B. `browser-with-recovery` (der eingebaute `browser`-Flow ist read-only; deshalb duplizieren).
2) Öffnet den duplizierten Flow. Im Subflow, der den OTP-Step enthält (typischerweise `… Browser - Conditional 2FA`), findet ihr die Ausführung **Recovery Authentication Code Form** bereits — aber auf **Disabled**. Setzt sie auf **Alternative**, damit sie gleichrangig neben dem OTP-Step steht.
3) Bindet den neuen Flow als Browser-Flow: oben rechts **Action → Bind flow → Browser flow → browser-with-recovery → Save**.
4) Setzt die Required Action gezielt für unseren Benutzer: **Users → labuser → Required user actions** → `Recovery Authentication Codes` hinzufügen → **Save**. (Die Required Action selbst ist unter **Authentication → Required actions** bereits global aktiviert; dort ist nichts zu tun.)

> Tipp bei Problemen: Wenn in Teil 4 die Auswahl "Recovery Authentication Code" beim Login nicht erscheint, ist meistens der Flow nicht korrekt gebunden oder der Step noch auf *Disabled* — prüft Schritt 2 und 3.

### Teil 3: Recovery Codes generieren (User-Perspektive)

1) Öffnet wieder ein privates Browserfenster und loggt euch als `labuser` ein — Passwort und TOTP wie gewohnt.
2) Keycloak zeigt nun die Required Action und generiert 12 Recovery Codes.
3) **Speichert die Codes lokal ab** (im echten Betrieb: Passwortmanager, Ausdruck, Tresor; fürs Lab reicht eine `.txt` neben diesem README). Bestätigt anschließend, dass ihr die Codes gespeichert habt.
4) Der Login ist damit abgeschlossen.

### Teil 4: Device verloren — Login per Recovery Code

Szenario: Der Benutzer hat sein TOTP-Gerät nicht mehr (Handy verloren, gestohlen, …) und muss sich trotzdem einloggen.

1) Öffnet erneut ein privates Browserfenster, ruft die Account Console auf und loggt euch als `labuser` mit dem Passwort ein.
2) Im Schritt für den zweiten Faktor wählt ihr unten **"Try Another Way"** (bzw. *"Anmelden mit einem anderen Verfahren"*).
3) Wählt **Recovery Authentication Code** aus der Liste der Methoden.
4) Gebt einen eurer gespeicherten Recovery Codes ein → Login erfolgreich.
5) Beachtet: Jeder Code ist nur einmal nutzbar. Den eben verwendeten Code könnt ihr aus eurer Liste streichen.

### User Self-Service

Damit ist die Übung abgeschlossen: Der Benutzer kann sich ab jetzt **selbst helfen**. In der Account Console unter **Account Security → Signing in** sieht er alle konfigurierten Methoden (Authenticator-App, Recovery Codes) und kann eigenständig neue Recovery Codes generieren, ein neues TOTP-Gerät registrieren oder das alte entfernen — ohne dass der Admin eingreifen muss. Genau das ist der Wert dieses Setups: Der Verlust eines zweiten Faktors ist kein Helpdesk-Ticket mehr, sondern ein Self-Service-Vorgang.

---

## EN

Goal: You will learn how users self-enroll a second factor (TOTP) in Keycloak, how the admin additionally enables recovery codes as a fallback, and how a user can log in with a recovery code if their TOTP device is lost.

### Setup

1) Navigate to this folder on the command line and run `docker compose up`. Wait until the log shows `Imported realm lab-realm` — the realm `lab-realm` with the user `labuser` is then automatically imported.
2) Log in as admin at http://localhost:8080 with `admin` / `admin` and switch to the realm `lab-realm`.

### Part 1: TOTP setup on first login (user perspective)

The user `labuser` already has the required action `Configure OTP` preset — on the first login Keycloak forces them to configure a TOTP authenticator.

1) Open a private browser window (so you can stay logged in as admin in parallel) and open the Account Console: http://localhost:8080/realms/lab-realm/account/
2) Log in with `labuser` / `labuser`.
3) Keycloak displays a QR code. Scan it with an authenticator app of your choice (Google Authenticator, FreeOTP, 1Password, Bitwarden, …) and confirm the 6-digit code.
4) Log out and log in again — this time you are asked for password **and** TOTP code.

### Part 2: Enable recovery codes (admin perspective)

Background: In Keycloak 26.6.2, the required action `Recovery Authentication Codes` is already enabled, and the `Recovery Authentication Code Form` step is already present in the default browser flow — but **disabled**. Without enabling it, the user can generate the codes but cannot use them instead of their TOTP code at login — which is exactly what we want for the recovery scenario in Part 4.

1) As admin, switch to the `lab-realm` realm, then go to **Authentication → Flows → browser**. Click **Duplicate** in the top-right and pick a name, e.g. `browser-with-recovery` (the built-in `browser` flow is read-only, so duplicate it).
2) Open the duplicated flow. Inside the subflow that contains the OTP step (typically `… Browser - Conditional 2FA`), you will already find the **Recovery Authentication Code Form** execution — but set to **Disabled**. Switch it to **Alternative** so it sits on equal footing with the OTP step.
3) Bind the new flow as the browser flow: top-right **Action → Bind flow → Browser flow → browser-with-recovery → Save**.
4) Apply the required action to our user explicitly: **Users → labuser → Required user actions** → add `Recovery Authentication Codes` → **Save**. (The required action itself is already globally enabled under **Authentication → Required actions**; nothing to do there.)

> Hint if things break: if the "Recovery Authentication Code" choice does not show up at login in Part 4, the flow is usually not bound correctly or the step is still on *Disabled* — re-check steps 2 and 3.

### Part 3: Generate recovery codes (user perspective)

1) Open a private browser window again and log in as `labuser` — password and TOTP as usual.
2) Keycloak now shows the required action and generates 12 recovery codes.
3) **Save the codes locally** (in real life: password manager, printout, vault; for the lab a `.txt` next to this README is fine). Then confirm that you have saved the codes.
4) The login is now complete.

### Part 4: Device lost — log in with a recovery code

Scenario: The user no longer has their TOTP device (phone lost, stolen, …) and still needs to log in.

1) Open a private browser window again, open the Account Console, and log in as `labuser` with the password.
2) On the second-factor step, click **"Try Another Way"** at the bottom.
3) Pick **Recovery Authentication Code** from the list of methods.
4) Enter one of your stored recovery codes → login successful.
5) Note: every code is single-use. Strike the code you just used off your list.

### User Self-Service

This concludes the exercise: the user can now **help themselves**. In the Account Console under **Account Security → Signing in**, they see all configured methods (authenticator app, recovery codes) and can independently generate new recovery codes, register a new TOTP device, or remove the old one — without admin intervention. That is the value of this setup: losing a second factor is no longer a helpdesk ticket but a self-service flow.
