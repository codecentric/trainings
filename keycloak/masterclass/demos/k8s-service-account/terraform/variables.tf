variable "kubernetes_issuer" {
  description = "The SA token issuer of the Kubernetes cluster. Must match the `iss` claim in service account tokens. Discover with: kubectl create token default | cut -d. -f2 | base64 -d 2>/dev/null | python3 -c \"import sys,json; print(json.load(sys.stdin)['iss'])\""
  type        = string
  default     = "https://kubernetes.default.svc"
}
