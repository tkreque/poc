#################
# Output
#################

output "kms_key_arn" {
  value = aws_kms_key.kms.arn
}

output "kms_key_id" {
  value = aws_kms_key.kms.key_id
}
