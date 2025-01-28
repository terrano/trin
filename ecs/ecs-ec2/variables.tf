variable "prj_id" {
  description = "Unique Project Identifier"
  type        = string
  default     = "ohio-1"
}

variable "prj_name" {
  description = "Default name of Spring Petclinic Project"
  type        = string
  default     = "spring-petclinic"
}

variable "region" {
  description = "Local region"
  type        = string
  default     = "us-east-2"
}

variable "default" {
  description = "Default route or subnet value."
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  description = "CIDR for VPC."
  type        = string
  default     = "172.31.0.0/16"
}

variable "network_tag" {
  type = map(string)
  default = {
    component = "network"
  }
}

variable "ecs_tag" {
  type = map(string)
  default = {
    component = "computing"
  }
}

variable "policy_role_tag" {
  type = map(string)
  default = {
    component = "iam"
  }
}

variable "security_tag" {
  type = map(string)
  default = {
    component = "security"
  }
}

variable "launch_template" {
  type = map(string)
  default = {
    component = "computing"
  }
}

locals {
  prj_full_name = join("-", [var.prj_id, var.prj_name])
}

variable "ecs_cluster_name" {
  type    = string
  default = "spc-ecs"
}

variable "esc_agent_cluster_name" {
  type    = string
  default = <<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=spc-ecs" > /etc/ecs/ecs.config
              systemctl enable --now --no-block ecs.service
              EOF
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
      availability_zone = subnet_key == "public_a" ? local.region_a : local.region_b
    }
  }
}

variable "iam_roles" {
  description = "ARN's of common AWS Policies"
  type        = map(string)
  default = {
    "ssm" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    "ecs" = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  }
}

########  Values in relation to region ########
variable "region_config" {
  description = "Map of regional ID's"
  type = map(object({
    docker_image_arn = string
    ssm_endpoints    = set(string)
    ecr_endpoints    = set(string)
    ecr_s3_endpoint  = string
    ecs_endpoints    = set(string)
  }))
  default = {
    "us-east-2" = {
      docker_image_arn = "arn:aws:ecr:us-east-2:211125418581:repository/spring-petclinic-image"
      ssm_endpoints    = ["com.amazonaws.us-east-2.ssm", "com.amazonaws.us-east-2.ssmmessages", "com.amazonaws.us-east-2.ec2messages"]
      ecr_endpoints    = ["com.amazonaws.us-east-2.ecr.api", "com.amazonaws.us-east-2.ecr.dkr"]
      ecr_s3_endpoint  = "com.amazonaws.us-east-2.s3"
      ecs_endpoints    = ["com.amazonaws.us-east-2.ecs", "com.amazonaws.us-east-2.ecs-agent", "com.amazonaws.us-east-2.ecs-telemetry"]
    },
    "eu-central-1" = {
      docker_image_arn = "arn:aws:ecr:eu-central-1:211125418581:repository/spring-petclinic-image"
      ssm_endpoints    = ["com.amazonaws.eu-central-1.ssm", "com.amazonaws.eu-central-1.ssmmessages", "com.amazonaws.eu-central-1.ec2messages"]
      ecr_endpoints    = ["com.amazonaws.eu-central-1.ecr.api", "com.amazonaws.eu-central-1.ecr.dkr"]
      ecr_s3_endpoint  = "com.amazonaws.eu-central-1.s3"
      ecs_endpoints    = ["com.amazonaws.eu-central-1.ecs", "com.amazonaws.eu-central-1.ecs-agent", "com.amazonaws.eu-central-1.ecs-telemetry"]
    }
  }
}

variable "image_types" {
  type = map(string)
  default = {
    "t2micro" = "t2.micro"
    "t2small" = "t2.small"
  }
}