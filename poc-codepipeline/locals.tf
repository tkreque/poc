locals {
  cicd = {
    pipeline = {
      name = "poc-pipeline"
    }
    build = {
      name = "poc-codebuild"
      timeout = 10
      buildspec = "deployment/deploy.yml"
    }
  }
  ecr = {
    name = "<my_ecr_repository_name>",
    image_tag = "latest"
  }
}