# Demo: Kubernetes Service Account Authentication

## DE

Dienste in einem Kubernetes-Cluster müssen sich häufig bei Keycloak authentifizieren, um Tokens für den Zugriff auf andere Dienste zu erhalten. Der naive Ansatz – ein statisches Client-Secret als Kubernetes-Secret verwalten – ist fehleranfällig, rotationsaufwendig und schwer zu auditieren.

Dieses Demo zeigt die moderne Alternative: Ein Pod verwendet sein **Kubernetes Service Account Token** direkt als Client-Credential bei Keycloak. Kein statisches Secret wird verteilt. Keycloak validiert das SA-Token über den Kubernetes-JWKS-Endpunkt und stellt ein Keycloak-Zugriffstoken aus.

Dies nutzt Keycloaks natives **Federated Client Authentication**-Feature (GA seit Keycloak 26.6).

### Konzept

```
Pod (in K8s)                        Keycloak (in K8s)             K8s API Server
 |                                       |                               |
 | 1. Liest projiziertes SA-Token        |                               |
 |    (aud = Keycloak Realm Issuer URL)  |                               |
 |                                       |                               |
 | 2. POST /token                        |                               |
 |    grant_type=client_credentials      |                               |
 |    client_assertion=<SA-JWT> ───────▶ |                               |
 |                                       | 3. GET /.well-known/          |
 |                                       |    openid-configuration ────▶ |
 |                                       |◀── JWKS ──────────────────── |
 |                                       | 4. Validiert JWT              |
 |◀── Keycloak Access Token ──────────── |    (Signatur, aud, sub)       |
```

**Keycloak konfiguriert einen Kubernetes Identity Provider**, der die öffentlichen Schlüssel vom K8s-API-Server bezieht. Der Client `workload-service` ist an den `sub`-Claim des Service Accounts gebunden (`system:serviceaccount:default:demo-workload`). Kein Client-Secret wird benötigt.

Da Keycloak den K8s-JWKS-Endpunkt (`https://kubernetes.default.svc`) erreichen muss, **läuft Keycloak im selben Kubernetes-Cluster**.

### Voraussetzungen

- Lokaler Kubernetes-Cluster (z.B. [kind](https://kind.sigs.k8s.io/), [k3d](https://k3d.io/) oder [minikube](https://minikube.sigs.k8s.io/))
- `kubectl` konfiguriert und verbunden
- [Helm](https://helm.sh/) installiert
- [Terraform](https://www.terraform.io/) installiert

### Setup

1. Helm-Repo hinzufügen (falls noch nicht vorhanden):
   ```bash
   helm repo add codecentric https://codecentric.github.io/helm-charts
   helm repo update
   ```

2. Keycloak im Cluster installieren:
   ```bash
   helm install keycloak codecentric/keycloakx --values values.yaml
   ```
   > **Hinweis:** Das `values.yaml` setzt `http.relativePath: "/"`, damit Keycloak unter dem Root-Pfad erreichbar ist (Standard des codecentric-Charts ist `/auth`).

3. Warten bis der Pod läuft:
   ```bash
   kubectl get pods -w
   ```

4. Port-Forward einrichten (für Admin-UI und Terraform):
   ```bash
   kubectl port-forward svc/keycloak-keycloakx-http 8080:80
   ```
   Keycloak ist jetzt unter http://localhost:8080 erreichbar (admin / admin).

5. Den genauen Keycloak-Service-Namen im Cluster prüfen – er wird für die SA-Token-Audience benötigt:
   ```bash
   kubectl get svc | grep keycloak
   ```
   Der Standard-Name des codecentric-Charts lautet `keycloak-keycloakx-http`.

6. Den SA-Token-Issuer des Clusters ermitteln:
   ```bash
   kubectl create token default | cut -d. -f2 | base64 -d 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['iss'])"
   ```
   Der Wert entspricht dem `--service-account-issuer`-Flag des API-Servers und ist cluster-spezifisch (z.B. `https://kubernetes.default.svc.cluster.local` bei k3d/kind).

7. Terraform initialisieren und anwenden (Port-Forward muss aktiv sein):
   ```bash
   cd terraform
   terraform init
   terraform apply -var="kubernetes_issuer=<ISSUER>"
   ```
   Falls der Issuer `https://kubernetes.default.svc` ist (Standard), kann `-var` weggelassen werden.
   Terraform legt an: Realm `lab-realm`, Kubernetes Identity Provider, einen angepassten Client-Auth-Flow und den Client `workload-service`.

7. Kubernetes-Manifeste deployen:
   ```bash
   kubectl apply -f manifests/
   ```
   Dies erstellt den Service Account `demo-workload` und den Pod `test-pod` mit einem projizierten SA-Token.

### Was konfiguriert wird

| Ressource | Beschreibung |
|---|---|
| Realm `lab-realm` | Demo-Realm |
| Kubernetes Identity Provider `kubernetes` | Validiert SA-Tokens via K8s-JWKS |
| Auth-Flow `clients-federated-jwt` | Akzeptiert SA-JWTs statt Client-Secrets |
| Client `workload-service` | Gebunden an `system:serviceaccount:masterclass:demo-workload` |
| ServiceAccount `demo-workload` | Kubernetes-Identität des Demo-Workloads |
| Pod `test-pod` | curl-Pod mit projiziertem SA-Token |

### Demo-Ablauf

1. Shell in den Pod öffnen:
   ```bash
   kubectl exec -it test-pod -- sh
   ```

2. Das SA-Token anzeigen und dekodieren (zeigt `iss`, `sub`, `aud` – kein Secret):
   ```bash
   cat /var/run/secrets/keycloak/token
   ```
   Den Token-Wert auf [jwt.io](https://jwt.io) einfügen und die Claims betrachten:
   - `iss`: the cluster's SA token issuer (e.g. `https://kubernetes.default.svc.cluster.local`)
   - `sub`: `system:serviceaccount:masterclass:demo-workload`
   - `aud`: `http://keycloak-keycloakx-http/realms/lab-realm`

3. SA-Token gegen ein Keycloak-Zugriffstoken tauschen:
   ```bash
   curl -s \
     "http://keycloak-keycloakx-http/realms/lab-realm/protocol/openid-connect/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     --data-urlencode "grant_type=client_credentials" \
     --data-urlencode "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
     --data-urlencode "client_assertion=$(cat /var/run/secrets/keycloak/token)"
   ```

4. Das Keycloak-Zugriffstoken auf [jwt.io](https://jwt.io) dekodieren:
   - `azp`: `workload-service` – Keycloak hat den richtigen Client identifiziert
   - `iss`: `http://keycloak-keycloakx-http/realms/lab-realm`
   - Kein Benutzername, kein statisches Secret wurde verwendet

### Hinweise

- Der `keycloak_authentication_bindings`-Flow gilt realm-weit. In produktiven Umgebungen sollten Client-Authentication-Flows auf Client-Ebene gebunden werden.
- Das SA-Token läuft nach 600 Sekunden ab (Kubernetes-Minimum für projizierte Tokens: 600s, Maximum: 3600s). Der Pod erhält automatisch ein neues Token.

### Cleanup

```bash
kubectl delete -f manifests/
terraform destroy
helm uninstall keycloak
```

---

## EN

Services in a Kubernetes cluster often need to authenticate with Keycloak to obtain tokens for accessing other services. The naive approach — managing a static client secret as a Kubernetes Secret — is error-prone, rotation-heavy, and hard to audit.

This demo shows the modern alternative: a pod uses its **Kubernetes Service Account Token** directly as a client credential with Keycloak. No static secret is distributed. Keycloak validates the SA token via the Kubernetes JWKS endpoint and issues a Keycloak access token.

This leverages Keycloak's native **Federated Client Authentication** feature (GA since Keycloak 26.6).

### Concept

```
Pod (in K8s)                        Keycloak (in K8s)             K8s API Server
 |                                       |                               |
 | 1. Reads projected SA token           |                               |
 |    (aud = Keycloak Realm Issuer URL)  |                               |
 |                                       |                               |
 | 2. POST /token                        |                               |
 |    grant_type=client_credentials      |                               |
 |    client_assertion=<SA JWT> ───────▶ |                               |
 |                                       | 3. GET /.well-known/          |
 |                                       |    openid-configuration ────▶ |
 |                                       |◀── JWKS ──────────────────── |
 |                                       | 4. Validates JWT              |
 |◀── Keycloak Access Token ──────────── |    (signature, aud, sub)      |
```

**Keycloak configures a Kubernetes Identity Provider** that fetches public keys from the K8s API server. The client `workload-service` is bound to the Service Account's `sub` claim (`system:serviceaccount:masterclass:demo-workload`). No client secret is needed.

Since Keycloak must reach the K8s JWKS endpoint (`https://kubernetes.default.svc`), **Keycloak runs in the same Kubernetes cluster**.

### Prerequisites

- Local Kubernetes cluster (e.g. [kind](https://kind.sigs.k8s.io/), [k3d](https://k3d.io/), or [minikube](https://minikube.sigs.k8s.io/))
- `kubectl` configured and connected
- [Helm](https://helm.sh/) installed
- [Terraform](https://www.terraform.io/) installed

### Setup

1. Add the Helm repo (if not already added):
   ```bash
   helm repo add codecentric https://codecentric.github.io/helm-charts
   helm repo update
   ```

2. Install Keycloak in the cluster:
   ```bash
   helm install keycloak codecentric/keycloakx --values values.yaml
   ```
   > **Note:** `values.yaml` sets `http.relativePath: "/"` so Keycloak is reachable at the root path (the codecentric chart defaults to `/auth`).

3. Wait for the pod to be ready:
   ```bash
   kubectl get pods -w
   ```

4. Set up port-forwarding (for the Admin UI and Terraform):
   ```bash
   kubectl port-forward svc/keycloak-keycloakx-http 8080:80
   ```
   Keycloak is now available at http://localhost:8080 (admin / admin).

5. Verify the exact Keycloak service name in the cluster — it is needed for the SA token audience:
   ```bash
   kubectl get svc | grep keycloak
   ```
   The default name for the codecentric chart is `keycloak-keycloakx-http`.

6. Discover the cluster's SA token issuer:
   ```bash
   kubectl create token default | cut -d. -f2 | base64 -d 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['iss'])"
   ```
   This reflects the API server's `--service-account-issuer` flag and is cluster-specific (e.g. `https://kubernetes.default.svc.cluster.local` on k3d/kind).

7. Initialize and apply Terraform (port-forward must be active):
   ```bash
   cd terraform
   terraform init
   terraform apply -var="kubernetes_issuer=<ISSUER>"
   ```
   If the issuer is `https://kubernetes.default.svc` (the default), the `-var` flag can be omitted.
   Terraform creates: realm `lab-realm`, Kubernetes Identity Provider, a custom client auth flow, and the client `workload-service`.

8. Deploy Kubernetes manifests:
   ```bash
   kubectl apply -f manifests/
   ```
   This creates the `demo-workload` Service Account and the `test-pod` with a projected SA token.

### What gets configured

| Resource | Description |
|---|---|
| Realm `lab-realm` | Demo realm |
| Kubernetes Identity Provider `kubernetes` | Validates SA tokens via K8s JWKS |
| Auth flow `clients-federated-jwt` | Accepts SA JWTs instead of client secrets |
| Client `workload-service` | Bound to `system:serviceaccount:masterclass:demo-workload` |
| ServiceAccount `demo-workload` | Kubernetes identity of the demo workload |
| Pod `test-pod` | curl pod with projected SA token |

### Demo walkthrough

1. Open a shell in the pod:
   ```bash
   kubectl exec -it test-pod -- sh
   ```

2. Display and decode the SA token (shows `iss`, `sub`, `aud` — no secret):
   ```bash
   cat /var/run/secrets/keycloak/token
   ```
   Paste the token value into [jwt.io](https://jwt.io) and inspect the claims:
   - `iss`: the cluster's SA token issuer (e.g. `https://kubernetes.default.svc.cluster.local`)
   - `sub`: `system:serviceaccount:masterclass:demo-workload`
   - `aud`: `http://keycloak-keycloakx-http/realms/lab-realm`

3. Exchange the SA token for a Keycloak access token:
   ```bash
   curl -s \
     "http://keycloak-keycloakx-http/realms/lab-realm/protocol/openid-connect/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     --data-urlencode "grant_type=client_credentials" \
     --data-urlencode "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
     --data-urlencode "client_assertion=$(cat /var/run/secrets/keycloak/token)"
   ```

4. Decode the Keycloak access token at [jwt.io](https://jwt.io):
   - `azp`: `workload-service` — Keycloak identified the correct client
   - `iss`: `http://keycloak-keycloakx-http/realms/lab-realm`
   - No username, no static secret was involved

### Notes

- The `keycloak_authentication_bindings` flow applies realm-wide. In production environments, client authentication flows should be bound at the client level.
- The SA token expires after 600 seconds (Kubernetes minimum for projected tokens: 600s, maximum: 3600s). The pod automatically receives a refreshed token.

### Cleanup

```bash
kubectl delete -f manifests/
terraform destroy
helm uninstall keycloak
```
