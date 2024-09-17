resource "aws_codebuild_project" "dev-build" {
  provider      = aws.dev
  name          = "${local.cicd_build_name}-dev"
  build_timeout = 10
  service_role  = aws_iam_role.dev-codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("deploy.yml")
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

resource "aws_codebuild_project" "prod-build" {
  provider      = aws.prod
  name          = "${local.cicd_build_name}-prod"
  build_timeout = 10
  service_role  = aws_iam_role.prod-codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("deploy.yml")
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

#### IAM
resource "aws_iam_role" "dev-codebuild" {
  provider = aws.dev
  name     = "${local.cicd_build_name}-dev-iam-role"
  path     = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          Service = "codebuild.amazonaws.com"
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
            "eks:DescribeCluster",
            "iam:GetOpenIDConnectProvider",
            "iam:CreateOpenIDConnectProvider",
            "iam:TagOpenIDConnectProvider",
            "iam:CreatePolicy"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:CreateNetworkInterfacePermission"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "ec2:AuthorizedService" = [
                "codebuild.amazonaws.com"
              ]
            }
          }
        },
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
        }
      ]
    })
  }
}

resource "aws_iam_policy" "dev-codebuild" {
  provider   = aws.dev
  depends_on = [aws_kms_key.codepipeline_kms_key]
  name       = "${local.cicd_build_name}-dev-iam-role-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.codepipeline_kms_key.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dev-codebuild" {
  provider   = aws.dev
  depends_on = [aws_iam_policy.dev-codebuild]
  role       = aws_iam_role.dev-codebuild.name
  policy_arn = aws_iam_policy.dev-codebuild.arn
}

resource "aws_iam_role" "prod-codebuild" {
  provider = aws.prod
  name     = "${local.cicd_build_name}-prod-iam-role"
  path     = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          Service = "codebuild.amazonaws.com"
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
            "eks:DescribeCluster",
            "iam:GetOpenIDConnectProvider",
            "iam:CreateOpenIDConnectProvider",
            "iam:TagOpenIDConnectProvider",
            "iam:CreatePolicy"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeDhcpOptions",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:CreateNetworkInterfacePermission"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "ec2:AuthorizedService" = [
                "codebuild.amazonaws.com"
              ]
            }
          }
        },
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
        }
      ]
    })
  }
}

resource "aws_iam_policy" "prod-codebuild" {
  provider   = aws.prod
  depends_on = [aws_kms_key.codepipeline_kms_key]
  name       = "${local.cicd_build_name}-prod-iam-role-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.codepipeline_kms_key.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prod-codebuild" {
  provider   = aws.prod
  depends_on = [aws_iam_policy.prod-codebuild]
  role       = aws_iam_role.prod-codebuild.name
  policy_arn = aws_iam_policy.prod-codebuild.arn
}
