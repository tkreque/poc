locals {
  k8s = {
    context = "minikube"
    config  = "~/.kube/config"
  }
  app = {
    names = {
      application    = var.configs.env_vars.k8s.app.name
      namespace      = try(var.configs.env_vars.k8s.app.namespace, "${var.configs.env_vars.account.environment}-${var.configs.env_vars.k8s.app.name}")
      configmap      = "configmap-${var.configs.env_vars.k8s.app.name}"
      deployment     = var.configs.env_vars.k8s.app.name
      service        = "service-${var.configs.env_vars.k8s.app.name}"
      serviceaccount = "serviceaccount-${var.configs.env_vars.k8s.app.name}"
      ingress        = "ingress-${var.configs.env_vars.k8s.app.name}"
      secret         = "secret-${var.configs.env_vars.k8s.app.name}"
    }
  }
}