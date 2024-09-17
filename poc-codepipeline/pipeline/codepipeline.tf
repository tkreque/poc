resource "aws_codepipeline" "this" {
  depends_on = [
    aws_iam_role.codepipeline,
    aws_iam_role.dev-codepipeline,
    aws_iam_role.test-codepipeline
  ]
  name           = local.cicd_pipeline_name
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
        RepositoryName = "<ecr_repo_name>"
        ImageTag       = "latest"
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
    name = "ApprovalDev"

    action {
      name     = "ApprovalDev"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
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

#### S3
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "${local.cicd_pipeline_name}-s3-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CodeBuildGetObjects"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.dev.account_id}:root",
            "arn:aws:iam::${data.aws_caller_identity.prod.account_id}:root"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.codepipeline_bucket.arn,
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket" {
  depends_on = [aws_kms_key.codepipeline_kms_key]
  bucket     = aws_s3_bucket.codepipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codepipeline_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#### KMS
resource "aws_kms_key" "codepipeline_kms_key" {
  depends_on  = [aws_iam_role.dev-codebuild, aws_iam_role.prod-codebuild]
  description = "${local.cicd_pipeline_name}-kms-key"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.prime.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.dev-codebuild.arn,
            aws_iam_role.prod-codebuild.arn
          ]
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

#### IAM
resource "aws_iam_role" "codepipeline" {
  name = "${local.cicd_pipeline_name}-iam-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Effect = "Allow"
      }
    ]
  })

  inline_policy {
    name = "inline"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObjectAcl",
            "s3:PutObject"
          ]
          Resource = [
            aws_s3_bucket.codepipeline_bucket.arn,
            "${aws_s3_bucket.codepipeline_bucket.arn}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "sts:AssumeRole"
          ]
          Resource = [
            aws_iam_role.dev-codepipeline.arn,
            aws_iam_role.prod-codepipeline.arn
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:Describe*",
            "ecr:Get*"
          ]
          Resource = "<ecr_repo_arn>"
        },
        {
          Effect = "Allow"
          Action = [
            "kms:*"
          ]
          Resource = [
            aws_kms_key.codepipeline_kms_key.arn
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role" "dev-codepipeline" {
  provider = aws.dev
  name     = "${local.cicd_build_name}-prime-iam-role"
  path     = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.prime.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Effect = "Allow"
      }
    ]
  })

  inline_policy {
    name = "inline"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "codebuild:*"
          ]
          Resource = [
            aws_codebuild_project.dev-build.arn
          ]
        },
      ]
    })
  }
}

resource "aws_iam_role" "prod-codepipeline" {
  provider = aws.prod
  name     = "${local.cicd_build_name}-prime-iam-role"
  path     = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.prime.account_id}:root"
        }
        Action = "sts:AssumeRole"
        Effect = "Allow"
      }
    ]
  })

  inline_policy {
    name = "inline"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "codebuild:*"
          ]
          Resource = [
            aws_codebuild_project.prod-build.arn
          ]
        },
      ]
    })
  }
}