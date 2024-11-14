###################################################################################################
########################################## SECRETS CONFIG #########################################
###################################################################################################

#######  Random Password For Admin  ########
resource "random_password" "rds_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

#######  RDS Credentials Storage in AWS Secrets Manager  ########
resource "aws_secretsmanager_secret" "rds_admin_credentials" {
  name        = var.secret_manager_key_name
  kms_key_id  = aws_kms_key.credential_encryption_key.arn
  description = var.secret_manager_description
}

#######  Write Credentials Into Storage  ########
resource "aws_secretsmanager_secret_version" "rds_admin_credentials_version" {
  secret_id = aws_secretsmanager_secret.rds_admin_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds_admin_password.result
  })
}
