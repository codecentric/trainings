# Demo Helm

1) Check out the Repo: https://github.com/codecentric/helm-charts
2) Have K8s and Helm installed
3) Add the Repo to your Helm Repos: `helm repo add codecentric https://codecentric.github.io/helm-charts`
4) Create the `values.yaml` File
5) Install the Helm Chart: `helm install keycloak codecentric/keycloakx --values ./values.yaml`
6) Check, if the pods are running: `kubectl get pods`
7) Create the port forwarding:
```
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=keycloakx,app.kubernetes.io/instance=keycloak" -o name)
echo "Visit http://127.0.0.1:8080 to use your application"
kubectl --namespace default port-forward "$POD_NAME" 8080
```
8) Check if Keycloak is running at http://localhost:8080
9) Create 3 Replicas and allow the replicas to be on the same host (affinity). Add this to your `values.yaml`:
```
replicas: 3
affinity: ""
```
10) Reinstall the Chart (updating is not enough becouse of affinity change):
```
helm uninstall keycloak 
helm install keycloak codecentric/keycloakx --values ./values.yaml
```
11) All 3 Pods should be running after about 30-60s (`kubectl get pods`)
12) Create forwarding to the service to reach all replicas: `kubectl port-forward svc/keycloak-keycloakx-http 8080:80`