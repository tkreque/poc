terraform {
  source = "../../../..//layers/k8s/app"
}

dependency "rds" {
  config_path = "${get_terragrunt_dir()}/../../aws/rds"

  mock_outputs = {
    rds_instance_endpoints = ["mock-db-app:9999", "mock-db-reporting:9999"]
  }
}
