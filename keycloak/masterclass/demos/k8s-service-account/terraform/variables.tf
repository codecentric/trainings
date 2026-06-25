variable "kubernetes_issuer" {
  description = "The SA token issuer of the Kubernetes cluster. Must match the `iss` claim in service account tokens"
  type        = string
  default     = "https://kubernetes.default.svc"
}
