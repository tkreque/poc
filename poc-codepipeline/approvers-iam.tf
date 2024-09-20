resource "aws_iam_group" "approvers-test" {
  name = "ApproversTest"
}

resource "aws_iam_group" "approvers-prod-a" {
  name = "ApproversProdA"
}

resource "aws_iam_group" "approvers-prod-b" {
  name = "ApproversProdB"
}

resource "aws_iam_group_policy" "approvers-test-policy" {
  depends_on = [ aws_codepipeline.main ]
  name  = "ApproversTest-policy"
  group = aws_iam_group.approvers-test.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codepipeline:PutApprovalResult",
        ]
        Effect   = "Allow"
        Resource = "${aws_codepipeline.main.arn}:*/*/ApprovalTest"
      },
      {
        Action = [
          "codepipeline:Get*",
          "codepipeline:List*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy" "approvers-prod-a-policy" {
  depends_on = [ aws_codepipeline.main ]
  name  = "ApproversProdA-policy"
  group = aws_iam_group.approvers-prod-a.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codepipeline:PutApprovalResult",
        ]
        Effect   = "Allow"
        Resource = "${aws_codepipeline.main.arn}:*/*/ApprovalProdA"
      },
      {
        Action = [
          "codepipeline:Get*",
          "codepipeline:List*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy" "approvers-prod-b-policy" {
  depends_on = [ aws_codepipeline.main ]
  name  = "ApproversProdB-policy"
  group = aws_iam_group.approvers-prod-b.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codepipeline:PutApprovalResult",
        ]
        Effect   = "Allow"
        Resource = "${aws_codepipeline.main.arn}:*/*/ApprovalProdB"
      },
      {
        Action = [
          "codepipeline:Get*",
          "codepipeline:List*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}