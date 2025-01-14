terraform {
  backend "s3" {
    bucket         = "spring-clinic"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "spring-clinic-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = local.region_ohio

  default_tags {
    tags = {
      project            = "spring-petclinic"
      Environment        = terraform.workspace
      ManagedByTerraform = "True"
    }
  }
}

provider "aws" {
  region = local.region_frankfurt
  alias  = "aws_frankfurt"

  default_tags {
    tags = {
      project            = "spring-petclinic"
      Environment        = terraform.workspace
      ManagedByTerraform = "True"
    }
  }
}


locals {
  region_ohio      = "us-east-2"
  region_frankfurt = "eu-central-1"
  ohio_1           = "ohio-1"
  ohio_2           = "ohio-2"
  frankfurt_1      = "frankfurt-1"
}

module "deploy-petclininc-ohio1" {
  source = "./petclinic_deployment"
  region = local.region_ohio
  prj_id = local.ohio_1

}

module "deploy-petclininc-ohio2" {
  source   = "./petclinic_deployment"
  region   = local.region_ohio
  prj_id   = local.ohio_2
  vpc_cidr = "192.168.0.0/16"
}

module "deploy-petclininc-frankfurt" {
  source   = "./petclinic_deployment"
  region   = local.region_frankfurt
  prj_id   = local.frankfurt_1
  vpc_cidr = "10.10.0.0/16"

  providers = {
    aws = aws.aws_frankfurt
  }
}

output "load_balancers_dns1" {
  value = module.deploy-petclininc-ohio1.LB_link
}

output "load_balancers_dns2" {
  value = module.deploy-petclininc-ohio2.LB_link
}

output "load_balancers_dns3" {
  value = module.deploy-petclininc-frankfurt.LB_link
}

