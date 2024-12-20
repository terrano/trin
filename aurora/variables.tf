variable "region" {
  type    = string
  default = "us-east-1"
}

locals {
  region_a = "${var.region}a"
  region_b = "${var.region}b"
}

variable "aurora_cluster_name" {
  type    = string
  default = "trinity-poc-cluster"
}

variable "aurora_db_name" {
  type    = string
  default = "auroradb"
}

variable "secret_manager_key_name" {
  type    = string
  default = "rds/admin"
}


variable "subnet_group_name" {
  type    = string
  default = "test-rds-ec2-db-subnet-group-1"
}

variable "db_credentials" {
  type = map(string)
  default = {
    master_username = "postgres"
    master_password = "password"
  }
}

variable "credential_encryption_key_alias" {
  type    = string
  default = "alias/credential_encryption"
}