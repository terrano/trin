variable "name" {
  type    = string
  default = "AuroraDBKey"
}

variable "deletion_window_in_days" {
  type        = number
  default     = 20
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
}

variable "description" {
  type        = string
  default     = "RDS AuroraDB Encryption key"
}

variable "alias" {
  type        = string
  default     = "alias/rds_aurora_encryption"
}
