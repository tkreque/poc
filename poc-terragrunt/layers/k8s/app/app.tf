resource "kubernetes_namespace" "namespace" {
  metadata {
    labels = { "app.kubernetes.io/name" : local.app.names.application }

    name = local.app.names.namespace
  }
}

resource "kubernetes_manifest" "service_account" {
  depends_on = [kubernetes_namespace.namespace]

  manifest = yamldecode(templatefile("./manifests/serviceaccount.yml",
    {
      name        = local.app.names.serviceaccount
      namespace   = local.app.names.namespace
      application = local.app.names.application
    }
  ))
}

resource "kubernetes_manifest" "service" {
  depends_on = [kubernetes_manifest.service_account]

  manifest = yamldecode(templatefile("./manifests/service.yml",
    {
      name        = local.app.names.service
      namespace   = local.app.names.namespace
      application = local.app.names.application
      configs     = var.configs.env_vars.k8s.app
    }
  ))
}

resource "kubernetes_manifest" "ingress" {
  depends_on = [kubernetes_manifest.service]

  manifest = yamldecode(templatefile("./manifests/ingress.yml",
    {
      name        = local.app.names.ingress
      namespace   = local.app.names.namespace
      application = local.app.names.application
      configs     = var.configs.env_vars.k8s.app
      service     = local.app.names.service
    }
  ))
}

resource "kubernetes_manifest" "deployment" {
  depends_on = [kubernetes_manifest.ingress]

  manifest = yamldecode(templatefile("./manifests/deployment.yml",
    {
      name           = local.app.names.deployment
      namespace      = local.app.names.namespace
      serviceaccount = local.app.names.serviceaccount
      configmap      = local.app.names.configmap
      secret         = local.app.names.secret
      configs        = var.configs.env_vars.k8s.app
      environment    = var.configs.env_vars.account.environment
      application    = local.app.names.application
    }
  ))
}