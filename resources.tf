

###  ---  Default Modules  ---  ###
module "minio" {
  source = "./modules/minio"
   depends_on = [kubernetes_namespace.langsmith]
}

module "argo_events" {
  source = "./modules/argo_events"
  depends_on = [module.minio]
}

