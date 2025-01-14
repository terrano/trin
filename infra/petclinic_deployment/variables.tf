variable "prj_id" {
  description = "Unique Project Identifier"
  type = string
}

variable "prj_name" {
  description = "Default name of Spring Petclinic Project"
  type    = string
  default = "spring-petclinic"
}

variable "region" {
  description = "VPC region"
  type = string
  default = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR for VPC."
  type    = string
  default = "172.31.0.0/16"
}

variable "default" {
  description = "Default route or subnet value."
  type    = string
  default = "0.0.0.0/0"
}

variable "network_tag" {
  type = map(string)
  default = {
    component = "network"
  }
}

variable "security_tag" {
  type = map(string)
  default = {
    component = "security"
  }
}

variable "policy_role_tag" {
  type = map(string)
  default = {
    component = "iam"
  }
}

variable "ec2_tag" {
  type = map(string)
  default = {
    component = "computing"
  }
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
    "public_a" = {
      name              = "Public-A",
      cidr_block        = "",
      availability_zone = ""
    },
    "public_b" = {
      name              = "Public-B",
      cidr_block        = "",
      availability_zone = ""
    },
    "private_a" = {
      name              = "Private-A",
      cidr_block        = "",
      availability_zone = ""
    },
    "private_b" = {
      name              = "Private-B",
      cidr_block        = "",
      availability_zone = ""
    }
  }
}

locals {
  region_a = "${var.region}a"
  region_b = "${var.region}b"
}

 locals {
  actual_subnets_data = {
    for subnet_key, subnet_value in var.subnets_data :
    subnet_key => {
      name              = join("-", ["${local.prj_full_name}", subnet_value.name]),
      cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, index(keys(var.subnets_data), subnet_key))}",
      availability_zone = subnet_key == "public_a" || subnet_key == "private_a" ? local.region_a : local.region_b
    }
  }
}

variable "ssm_policy_arn" {
  description = "ARN of common AWS SSM Policy"
  type = string
  default = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

########  Values in relation to region ########
variable "region_config" {
  description = "Map of regional ID's"
  type = map(object({
    ami_id   = string
    docker_image_arn = string
    ssm_endpoints = set(string)
    ecr_endpoints = set(string)
    ecr_s3_endpoint = string
  }))
  default = {
    "us-east-2" = {
      ami_id = "ami-03b054aa09816a14a"
      docker_image_arn   = "arn:aws:ecr:us-east-2:211125418581:repository/spring-petclinic-image"
      ssm_endpoints = ["com.amazonaws.us-east-2.ssm", "com.amazonaws.us-east-2.ssmmessages", "com.amazonaws.us-east-2.ec2messages"]
      ecr_endpoints = ["com.amazonaws.us-east-2.ecr.api", "com.amazonaws.us-east-2.ecr.dkr"]
      ecr_s3_endpoint = "com.amazonaws.us-east-2.s3"
    },
    "eu-central-1" = {
      ami_id = "ami-0e35239b37b98687a"
      docker_image_arn   = "arn:aws:ecr:us-east-2:211125418581:repository/spring-petclinic-image"
      ssm_endpoints = ["com.amazonaws.eu-central-1.ssm", "com.amazonaws.eu-central-1.ssmmessages", "com.amazonaws.eu-central-1.ec2messages"]
      ecr_endpoints = ["com.amazonaws.eu-central-1.ecr.api", "com.amazonaws.eu-central-1.ecr.dkr"]
      ecr_s3_endpoint = "com.amazonaws.eu-central-1.s3"
    }
  }
}

locals {
  prj_full_name = join("-", [var.prj_id, var.prj_name])
  ami_id = var.region_config[var.region].ami_id
  docker_image_arn = var.region_config[var.region].docker_image_arn
}

variable "python_web_server" {
  type    = string
  default = <<-EOF
              #!/bin/bash
              echo "Hello, World 3" > index.html
              python3 -m http.server 8080 &
              EOF
}
