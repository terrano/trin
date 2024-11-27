###################################################################################################
############################################ KMS CONFIG ###########################################
###################################################################################################

########  Key For DB Encryption  ########
resource "aws_kms_key" "rds_key" {
  description             = var.db_key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  tags = {
    Name : var.db_key_name
  }
}

########  Alias For Key For DB Encryption  ########
resource "aws_kms_alias" "rds_key_alias" {
  name          = var.db_alias
  target_key_id = join("", aws_kms_key.rds_key.*.id)
}

########  Key For Encrypting RDS Credentials  ########
resource "aws_kms_key" "credential_encryption_key" {
  description             = var.credential_encryption_key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

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
    Name : var.credential_encryption_name
  }
}

########  Alias For Key For RDS Secrets Encryption  ########
resource "aws_kms_alias" "credential_encryption_key_alias" {
  name          = var.credential_encryption_key_alias
  target_key_id = join("", aws_kms_key.credential_encryption_key.*.id)
}

 