
variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig for the target cluster"
  default     = "~/.kube/config"
}
variable "langsmith_api_key_salt" {
  description = "Stable secret used to hash LangSmith API keys. DO NOT ROTATE."
  type        = string
  sensitive   = true
}


