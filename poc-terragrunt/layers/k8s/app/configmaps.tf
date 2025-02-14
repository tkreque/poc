resource "kubernetes_manifest" "configmap_dev" {
  depends_on = [kubernetes_namespace.namespace]

  count = var.configs.env_vars.account.environment == "dev" ? 1 : 0
  manifest = yamldecode(templatefile("./manifests/configmaps/${var.configs.env_vars.account.environment}.yml",
    {
      name        = local.app.names.configmap
      namespace   = local.app.names.namespace
      application = local.app.names.application
      is_dev      = true
    }
  ))
}

resource "kubernetes_manifest" "configmap_test" {
  depends_on = [kubernetes_namespace.namespace]

  count = var.configs.env_vars.account.environment == "test" ? 1 : 0
  manifest = yamldecode(templatefile("./manifests/configmaps/${var.configs.env_vars.account.environment}.yml",
    {
      name        = local.app.names.configmap
      namespace   = local.app.names.namespace
      application = local.app.names.application
      is_dev      = false
      is_test     = true
    }
  ))
}