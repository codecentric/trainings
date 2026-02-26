# Lab Passkeys

# DE

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

---

# EN

## Part One: Second Factor

Goal: Force users to configure a second factor for login.

1) Navigate to this folder on the command line and run `docker compose up`.
2) Create a new realm "lab-realm" and switch to it.
3) Create a new user in the realm. The user must be fully configured ("Email verified", password set, password not "temporary").
4) To use passkeys as a second factor, the step "WebAuthN Authenticator" must be enabled as an alternative in the Browser Flow (Authentication -> Browser). To do this, you need to duplicate the flow, then edit, save, and bind it.
5) To force the user to set up an OTP on the next login, add the Required Action "Configure OTP". Alternatively, the user can be prompted with the Required Action "WebAuthN Register" to register a passkey as a second factor.
6) Log in with the user to the Account Console. If you want to stay logged in as admin in parallel, use a private browser window or a different browser: http://localhost:8080/realms/lab-realm/account/
7) Follow the displayed steps and test the success of the second factor with a second login attempt.

## Part Two: Login via Passkey

Goal: Allow users to log in without a username using only a passkey.

1) Create another user in the "lab-realm".
2) Enable "Enable Passkeys" under Authentication -> Policies -> WebAuthN Passwordless Policy.
3) Either force the user to register a passkey on the next login (Required Action "WebAuthN Register Passwordless") or register a passkey in the Account Console under Account Security -> Signing in -> Passwordless.
4) Log in again with the passkey by selecting "Sign in with Passkey" on the login screen.
