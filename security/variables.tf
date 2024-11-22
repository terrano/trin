variable "deletion_window_in_days" {
  type    = number
  default = 20
}

variable "enable_key_rotation" {
  type    = bool
  default = true
}

variable "secret_manager_key_name" {
  type    = string
  default = "rds/admin"
}

variable "db_key_description" {
  type    = string
  default = "RDS AuroraDB Encryption key"
}

variable "db_alias" {
  type    = string
  default = "alias/rds_aurora_encryption"
}

variable "db_key_name" {
  type    = string
  default = "AuroraDBKey"
}

variable "credential_encryption_name" {
  type    = string
  default = "CredEncrKey"
}

variable "credential_encryption_key_description" {
  type    = string
  default = "RDS AuroraDB Credentials Encryption key"
}

variable "credential_encryption_key_alias" {
  type    = string
  default = "alias/credential_encryption"
}

variable "secret_manager_description" {
  type    = string
  default = "RDS Admin Credentials"
}

variable "db_username" {
  description = "The database admin username"
  type        = string
  default     = "db_admin"
}

