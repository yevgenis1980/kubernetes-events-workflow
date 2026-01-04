
###  ---  Default Modules  ---  ###
module "minio" {
  source = "./modules/minio"
   depends_on = [kubernetes_namespace.langsmith]
}

module "langsmith" {
  source = "./modules/langsmith"
  depends_on = [module.minio]
}

