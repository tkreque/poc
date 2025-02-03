data "aws_iam_policy_document" "ec2" {

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.configs.env_vars.account.id}:root"]
    }

    actions = ["kms:*"]

    resources = ["*"]
  }
}

resource "aws_kms_key" "ec2" {
  description              = "Used for Encrytion of Ec2 resources"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  is_enabled               = true
  enable_key_rotation      = true
  policy                   = data.aws_iam_policy_document.ec2.json
}

resource "aws_kms_alias" "ec2" {
  target_key_id = aws_kms_key.ec2.key_id
  name          = "alias/${var.configs.kms_name}"
}