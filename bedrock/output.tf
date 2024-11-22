output "a1" {
  value = aws_iam_policy.bedrock_fm_policy
}

output "a2" {
  value = aws_iam_policy.bedrock_rds_policy
}

output "a3" {
  value = aws_iam_policy.bedrock_s3_policy
}

output "a4" {
  value = data.aws_s3_bucket.s3_knowledgebase
}

output "a5" {
  value = data.aws_secretsmanager_secret.rds_admin_credentials
}

#output "a6" {
#  value = data.aws_iam_role.bedrock_knowledgebase_role
#}