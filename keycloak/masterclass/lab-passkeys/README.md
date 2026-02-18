# Lab Passkeys

## Erster Teil: Zweiter Faktor

Ziel: Benutzer dazu zwingen einen zweiten Faktor zum Login zu konfigurieren.

1) Wechselt auf der Kommandozeile in diesen Ordner und führt `docker compose up` aus.
2) Lege einen neuen Realm "lab-realm" an und wechsle in diesen.
3) Lege im Realm einen neuen Benutzer an. Der Benutzer muss vollständig konfiguriert sein ("EMail verified", Passwort hinterlegt, Passwort nicht "temporary".)
4) Damit Passkeys als zweiter Faktor genutzt werden können, muss im Browser Flow (Authentication -> Browser) der Step "WebAuthN Authenticator" als Alternative aktiviert werden. Dazu muss man den Flow duplizieren, dann editieren, speichern und binden.
5) Um den Benutzer beim nächsten Login zu zwingen ein OTP festzulegen, füge die Required Action "Configure OTP" hinzu. Alternativ kann der Benutzer mit der Required Action "WebAuthN Register" dazu aufgefordert werden einen Passkey als zweiten Faktor zu hinterlegen.
6) Logge dich mit dem Benutzer in die Account Console ein. Falls du parallel mit dem Admin eingeloggt bleiben willst, nutze ein privates Browserfenster oder einen anderen Browser: http://localhost:8080/realms/lab-realm/account/
7) Folge den angezeigten Schritten und erprobe bei einem zweiten Loginversuch den Erfolg des zweiten Faktors.

## Zweiter Teil: Login via Passkey

Ziel: Benutzern den Login ohne Benutzername nur mit Passkey erlauben.

1) Lege im "lab-realm" einen weiteren Benutzer an.
2) Aktiviere "Enable Passkeys" unter Authentication -> Policies -> WebAuthN Passwordless Policy.
3) Entweder zwingst du den Benutzer dazu bei nächsten Login einen Passkey zu registrieren (Required Action "WebAuthN Register Passwordless") oder hinterlege in der Account Console unter Account Security -> Signing in -> Passwordless einen Passkey.
4) Logge dich mit dem Passkey neu ein, indem du auf dem Login Screen "Sign in with Passkey" auswählst.
