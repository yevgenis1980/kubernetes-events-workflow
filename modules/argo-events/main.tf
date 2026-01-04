
resource "helm_release" "argo_events" {
  name             = "argo-events"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-events"
  version          = "2.4.9"
  namespace        = "argo-events"
  create_namespace = true
  wait             = true
  atomic           = true
  timeout          = 600
  dependency_update = true  # fetch charts from repo
}
