###################################################################################################
############################################ KMS CONFIG ###########################################
###################################################################################################

########  Key For DB Encryption  ########
resource "aws_kms_key" "rds_key" {
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  description             = var.db_key_description

  tags = {
    Name : var.db_key_name
  }
}

########  Alias For Key For DB Encryption  ########
resource "aws_kms_alias" "rds_key_alias" {
  name          = var.db_alias
  target_key_id = join("", aws_kms_key.rds_key.*.id)
}

########  Key For Encrypting RDS Secrets  ########
resource "aws_kms_key" "secrets_key" {
  description = var.secret_key_description
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-secrets-manager",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow RDS and Secrets Manager to use this key",
        Effect = "Allow",
        Principal = {
          Service = [
            "secretsmanager.amazonaws.com",
            "rds.amazonaws.com"
          ]
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name : var.secret_key_name
  }
}

########  Alias For Key For RDS Secrets Encryption  ########
resource "aws_kms_alias" "secrets_key_alias" {
  name          = var.secret_alias
  target_key_id = join("", aws_kms_key.secrets_key.*.id)
}

