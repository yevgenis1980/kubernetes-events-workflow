
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


resource "kubernetes_manifest" "eventbus_default" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "EventBus"
    metadata = {
      name      = "default"
      namespace = "argo-events"
    }
    spec = {
      nats = {
        native = {
          replicas = 1
        }
      }
    }
  }
}

resource "kubernetes_manifest" "velero_eventsource" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "EventSource"
    metadata = {
      name      = "velero-events"
      namespace = "argo-events" # optional, change if needed
    }
    spec = {
      eventBusName = "default"
      resource = {
        velero-backup-status = {
          group       = "velero.io"
          version     = "v1"
          resource    = "backups"
          eventTypes  = ["ADD", "UPDATE", "DELETE"]
          watchUpdates = true
          # namespace = "velero" # optional
        }
      }
    }
  }
}

resource "kubernetes_manifest" "velero_sensor" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Sensor"
    metadata = {
      name      = "velero-webhook-sensor"
      namespace = "argo-events"
    }
    spec = {
      eventBusName = "default"
      template = {
        serviceAccountName = "argo-events-sa"
      }
      dependencies = [
        {
          name            = "velero-backup-final"
          eventSourceName = "velero-events"
          eventName       = "velero-backup-status"
          filters = {
            data = [
              {
                path  = "body.status.phase"
                type  = "string"
                value = ["Completed", "Failed"]
              }
            ]
          }
        }
      ]
      triggers = [
        {
          template = {
            name = "send-status-to-webhook"
            http = {
              url    = "https://webhook.site/5b57aec3-bc8b-4a2d-a8f3-74e7906b6584"
              method = "POST"
              headers = {
                "Content-Type" = "application/json"
              }
              payload = [
                {
                  src = {
                    dependencyName = "velero-backup-final"
                    dataKey        = "body.metadata.name"
                  }
                  dest = "backup_name"
                },
                {
                  src = {
                    dependencyName = "velero-backup-final"
                    dataKey        = "body.status.phase"
                  }
                  dest = "status"
                }
              ]
            }
          }
        }
      ]
    }
  }
}
