variable "db_username" {
  description = "The database admin username"
  type        = string
  default     = "admin"
}

variable "deletion_window_in_days" {
  type    = number
  default = 20
}

variable "enable_key_rotation" {
  type    = bool
  default = true
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

variable "secret_key_name" {
  type    = string
  default = "SecretKeyEncr"
}

variable "secret_key_description" {
  type    = string
  default = "RDS AuroraDB Encryption key"
}

variable "secret_alias" {
  type    = string
  default = "alias/secrets_encryption"
}

variable "secret_manager_description" {
  type    = string
  default = "RDS Admin Credentials"
}