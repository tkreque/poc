resource "aws_codebuild_project" "dev-build" {
  provider      = aws.dev
  name          = "${local.cicd.build.name}-dev"
  build_timeout = local.cicd.build.timeout
  service_role  = aws_iam_role.dev-codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file(local.cicd.build.buildspec)
  }

  environment {
    privileged_mode             = true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "dev"
    }

  }
}

resource "aws_codebuild_project" "test-build" {
  provider      = aws.test
  name          = "${local.cicd.build.name}-test"
  build_timeout = local.cicd.build.timeout
  service_role  = aws_iam_role.test-codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file(local.cicd.build.buildspec)
  }

  environment {
    privileged_mode             = true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "test"
    }

  }
}

resource "aws_codebuild_project" "prod-build" {
  provider      = aws.prod
  name          = "${local.cicd.build.name}-prod"
  build_timeout = local.cicd.build.timeout
  service_role  = aws_iam_role.prod-codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file(local.cicd.build.buildspec)
  }

  environment {
    privileged_mode             = true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "prod"
    }

  }
}
