output "a1" {
  value = aws_iam_role.aws_rds_monitoring_role
}

output "a2" {
  value = aws_iam_role.aws_rds_monitoring_role.arn
}

output "a3" {
  value = aws_iam_role_policy_attachment.aws_rds_monitoring_policy
}