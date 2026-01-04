
resource "kubernetes_namespace" "argo_events" {
metadata {
name = "argo_events"
labels = {
"app.kubernetes.io/managed-by" = "terraform"
  }
 }
}
