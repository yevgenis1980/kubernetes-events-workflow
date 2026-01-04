
resource "helm_release" "langsmith" {
  name       = "langsmith"
  repository = "https://langchain-ai.github.io/helm/"
  chart      = "langsmith"
  namespace  = kubernetes_namespace.langsmith.metadata[0].name

  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      config = {
        existingSecretName = kubernetes_secret.langsmith.metadata[0].name
      }
    })
  ]

  depends_on = [
    kubernetes_secret.langsmith
  ]
}
