resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "${local.cicd.pipeline.name}-s3-bucket"
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
            "arn:aws:iam::${data.aws_caller_identity.test.account_id}:root",
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
  depends_on = [ aws_kms_key.codepipeline_kms_key ]
  bucket     = aws_s3_bucket.codepipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codepipeline_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}