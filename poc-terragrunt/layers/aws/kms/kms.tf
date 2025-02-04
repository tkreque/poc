data "aws_iam_policy_document" "kms" {

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

resource "aws_kms_key" "kms" {
  description              = "Used for Encrytion of AWS resources"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 30
  is_enabled               = true
  enable_key_rotation      = true
  policy                   = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "kms" {
  target_key_id = aws_kms_key.kms.key_id
  name          = "alias/${var.configs.kms_name}"
}