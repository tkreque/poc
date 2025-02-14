resource "kubernetes_secret" "secret_dev" {
  depends_on = [kubernetes_namespace.namespace]

  count = var.configs.env_vars.account.environment == "dev" ? 1 : 0
  type  = "Opaque"
  metadata {
    name      = local.app.names.secret
    namespace = local.app.names.namespace
    labels    = { "app.kubernetes.io/name" : local.app.names.application }
  }
  data = {
    DB_HOST     = var.rds_instance_endpoint
    DB_USER     = var.configs.env_vars.rds.db-app.authentication.users[0].user
    DB_PASSWORD = var.configs.env_vars.rds.db-app.authentication.users[0].password
  }
}

resource "kubernetes_secret" "secret_test" {
  depends_on = [kubernetes_namespace.namespace]

  count = var.configs.env_vars.account.environment == "test" ? 1 : 0
  type  = "Opaque"
  metadata {
    name      = local.app.names.secret
    namespace = local.app.names.namespace
    labels    = { "app.kubernetes.io/name" : local.app.names.application }
  }
  data = {
    DB_HOST               = var.rds_instance_endpoint
    DB_USER               = var.configs.env_vars.rds.db-app.authentication.users[0].user
    DB_PASSWORD           = var.configs.env_vars.rds.db-app.authentication.users[0].password
    REPORTING_DB_HOST     = try(var.rds_reporting_instance_endpoint, "")
    REPORTING_DB_USER     = var.configs.env_vars.rds.db-reporting.authentication.users[0].user
    REPORTING_DB_PASSWORD = var.configs.env_vars.rds.db-reporting.authentication.users[0].password
  }
}