
resource "kubernetes_namespace" "langsmith" {
metadata {
name = "langsmith"
labels = {
"app.kubernetes.io/managed-by" = "terraform"
  }
 }
}

resource "kubernetes_secret" "langsmith" {
  metadata {
    name      = "langsmith-secrets"
    namespace = kubernetes_namespace.langsmith.metadata[0].name
  }

  data = {
    API_KEY_SALT = base64encode(var.langsmith_api_key_salt)
  }

  type = "Opaque"
}
