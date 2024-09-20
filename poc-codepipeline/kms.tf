resource "aws_kms_key" "codepipeline_kms_key" {
  depends_on  = [
    aws_iam_role.dev-codebuild, 
    aws_iam_role.prod-codebuild
  ]
  description = "${local.cicd.pipeline.name}-kms-key"

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
            aws_iam_role.test-codebuild.arn,
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