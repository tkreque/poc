resource "aws_codepipeline" "main" {
  depends_on = [
    aws_iam_role.codepipeline,
    aws_iam_role.dev-codepipeline,
    aws_iam_role.test-codepipeline
  ]
  name           = local.cicd.pipeline.name
  role_arn       = aws_iam_role.codepipeline.arn
  execution_mode = "QUEUED"
  pipeline_type  = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.codepipeline_kms_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = local.ecr.name
        ImageTag       = local.ecr.image_tag
      }
    }
  }

  stage {
    name = "BuildDev"

    action {
      name            = "BuildDev"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.dev-build.name
      }

      role_arn = aws_iam_role.dev-codepipeline.arn
    }
  }

  stage {
    name = "ApprovalTest"

    action {
      name     = "ApprovalTest"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "BuildTest"

    action {
      name            = "BuildTest"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.test-build.name
      }

      role_arn = aws_iam_role.test-codepipeline.arn
    }
  }

  stage {
    name = "ApprovalProd"

    action {
      name     = "ApprovalProdA"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }

    action {
      name = "ApprovalProdB"
      category = "Approval"
      owner = "AWS"
      provider = "Manual"
      version = "1"
    }
  }

  stage {
    name = "BuildProd"

    action {
      name            = "BuildProd"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.prod-build.name
      }

      role_arn = aws_iam_role.prod-codepipeline.arn
    }
  }
}