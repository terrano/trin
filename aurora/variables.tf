variable "region" {
  type    = string
  default = "us-east-1"
}

locals {
  region_a = "${var.region}a"
  region_b = "${var.region}b"
}

variable "s3_bucket_knowleagebase_name" {
  type    = string
  default = "trinity-knowleadgebase-ingress"
}

variable "aurora_cluster_name" {
  type    = string
  default = "trinity-poc-cluster"
}

variable "aurora_db_name" {
  type    = string
  default = "auroradb"
}

variable "subnet_group_name" {
  type    = string
  default = "rds-ec2-db-subnet-group-1"
}

variable "db_credentials" {
  type = map(string)
  default = {
    master_username = "postgres"
    master_password = "password"
  }
}
