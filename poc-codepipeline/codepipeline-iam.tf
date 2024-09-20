resource "aws_iam_role" "codepipeline" {
  name = "${local.cicd.pipeline.name}-iam-role"
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
            aws_iam_role.test-codepipeline.arn,
            aws_iam_role.prod-codepipeline.arn
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "ecr:Describe*",
            "ecr:Get*"
          ]
          Resource = local.ecr.name
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
  name     = "${local.cicd.build.name}-devprime-iam-role"
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

resource "aws_iam_role" "test-codepipeline" {
  provider = aws.test
  name     = "${local.cicd.build.name}-testprime-iam-role"
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
            aws_codebuild_project.test-build.arn
          ]
        },
      ]
    })
  }
}

resource "aws_iam_role" "prod-codepipeline" {
  provider = aws.prod
  name     = "${local.cicd.build.name}-prodprime-iam-role"
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