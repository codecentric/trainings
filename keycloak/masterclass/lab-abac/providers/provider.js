// 1. Hol dir den Authorization Provider
var authProvider = $evaluation.getAuthorizationProvider();

// 2. Hol dir die Keycloak Session von dort
var session = authProvider.getKeycloakSession();

// 3. Hol dir den aktuellen Realm und die User-ID
var realm = session.getContext().getRealm();
var userId = $evaluation.getContext().getIdentity().getId();

// 4. Suche den User direkt in der Datenbank
var user = session.users().getUserById(realm, userId);

if (user !== null) {
    // Hol dir das Attribut (gibt den ersten Wert als String zurück)
    var department = user.getFirstAttribute('department');

    // Debug-Ausgabe in die Server-Logs
    print("DB-Check: User " + user.getUsername() + " hat Department: " + department);

    if (department === 'IT') {
        $evaluation.grant();
    }
}