variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "default" {
  type    = string
  default = "0.0.0.0/0"
}

locals {
  region_a = "${var.region}a"
  region_b = "${var.region}b"
}

########  Actual Subnets Info ########
variable "subnets_data" {
  description = "Default subnets information."
  type = map(object({
    name              = string,
    cidr_block        = string,
    availability_zone = string
  }))

  default = {
    "public_rds_a" = {
      name              = "RDS-Public-A",
      cidr_block        = "",
      availability_zone = ""
    },
    "public_rds_b" = {
      name              = "RDS-Public-B",
      cidr_block        = "",
      availability_zone = ""
    },
    "private_rds_a" = {
      name              = "RDS-Private-A",
      cidr_block        = "",
      availability_zone = ""
    },
    "private_rds_b" = {
      name              = "RDS-Private-B",
      cidr_block        = "",
      availability_zone = ""
    },
    "inner_rds_a" = {
      name              = "RDS-Inner-A",
      cidr_block        = "",
      availability_zone = ""
    },
    "inner_rds_b" = {
      name              = "RDS-Inner-B",
      cidr_block        = "",
      availability_zone = ""
    }
  }
}

locals {
  actual_subnets_data = {
    for subnet_key, subnet_value in var.subnets_data :
    subnet_key => {
      name              = subnet_value.name,
      cidr_block        = "${cidrsubnet(var.vpc_cidr, 9, index(keys(var.subnets_data), subnet_key))}",
      availability_zone = subnet_key == "public_rds_a" || subnet_key == "private_rds_a" || subnet_key == "inner_rds_a" ? local.region_a : local.region_b
    }
  }
}