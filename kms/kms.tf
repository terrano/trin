###################################################################################################
############################################ KMS CONFIG ###########################################
###################################################################################################
resource "aws_kms_key" "rds_key" {
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  description             = var.description

  tags = {
    Name : var.name
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = var.alias
  target_key_id = join("", aws_kms_key.rds_key.*.id)
}