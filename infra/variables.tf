variable "region" {
  type    = string
  default = "us-east-2"
}

variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "default" {
  type    = string
  default = "0.0.0.0/0"
}

variable "vpc_description" {
  type    = string
  default = "spring-petclinic-vpc"
}

variable "bucket_name" {
  type    = string
  default = "spring-clinic"
}

locals {
  lock_name = "${var.bucket_name}-state-lock"
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
  actual_subnets_data = {
    for subnet_key, subnet_value in var.subnets_data :
    subnet_key => {
      name              = subnet_value.name,
      cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, index(keys(var.subnets_data), subnet_key))}",
      availability_zone = subnet_key == "public_a" || subnet_key == "private_a" ? local.region_a : local.region_b
    }
  }
}

variable "ohio_ec2" {
  description = "Amazon machine image to use for ec2 instance id in Ohio"
  type        = string
  default     = "ami-03b054aa09816a14a"
}

variable "python_web_server" {
  type    = string
  default = <<-EOF
              #!/bin/bash
              echo "Hello, World 3" > index.html
              python3 -m http.server 8080 &
              EOF
}

variable "install_aws_docker" {
  type    = string
  default = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              sudo apt update
              sudo apt install -y python3 python3-pip unzip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install

              EOF  
}

variable "ssm_policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

variable "docker_image_arn" {
  type    = string
  default = "arn:aws:ecr:us-east-2:211125418581:repository/spring-petclinic-image"
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