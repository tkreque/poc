resource "aws_iam_role" "dev-codebuild" {
  provider = aws.dev
  name     = "${local.cicd.build.name}-dev-iam-role"
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
  depends_on = [ aws_kms_key.codepipeline_kms_key ]
  provider   = aws.dev
  name       = "${local.cicd.build.name}-dev-iam-role-policy"

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
  depends_on = [ aws_iam_policy.dev-codebuild ]
  provider   = aws.dev
  role       = aws_iam_role.dev-codebuild.name
  policy_arn = aws_iam_policy.dev-codebuild.arn
}

resource "aws_iam_role" "test-codebuild" {
  provider = aws.test
  name     = "${local.cicd.build.name}-test-iam-role"
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

resource "aws_iam_policy" "test-codebuild" {
  depends_on = [ aws_kms_key.codepipeline_kms_key ]
  provider   = aws.test
  name       = "${local.cicd.build.name}-test-iam-role-policy"

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

resource "aws_iam_role_policy_attachment" "test-codebuild" {
  depends_on = [ aws_iam_policy.test-codebuild ]
  provider   = aws.test
  role       = aws_iam_role.test-codebuild.name
  policy_arn = aws_iam_policy.test-codebuild.arn
}

resource "aws_iam_role" "prod-codebuild" {
  provider = aws.prod
  name     = "${local.cicd.build.name}-prod-iam-role"
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
  depends_on = [ aws_kms_key.codepipeline_kms_key ]
  provider   = aws.prod
  name       = "${local.cicd.build.name}-prod-iam-role-policy"

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
  depends_on = [ aws_iam_policy.prod-codebuild ]
  provider   = aws.prod
  role       = aws_iam_role.prod-codebuild.name
  policy_arn = aws_iam_policy.prod-codebuild.arn
}