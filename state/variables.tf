variable "region" {
  type    = string
  default = "us-east-2"
}

variable "bucket_name" {
  type    = string
  default = "spring-clinic"
}

locals {
  lock_name = "${var.bucket_name}-state-lock"
}
