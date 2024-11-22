output "a7" {
  value = aws_secretsmanager_secret.rds_admin_credentials
}

output "a8" {
  value = aws_secretsmanager_secret_version.rds_admin_credentials_version
}

output "a9" {
  value = random_password.rds_admin_password
}
