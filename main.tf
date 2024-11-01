terraform {
  backend "s3" {
    bucket         = "bedrock-infrastructure"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

#
#   1. Uncomment this section in order to deploy state file in aws which 
#      will track current state of infrastructure and prevent simultaneous work.
#
#      Once done, comment it back.
#
#module "deploy_terraform_state" {
#  source = "./terraform_aws_state"
#  region = "eu-west-1"
#}

#
#    Use this module to deploy aws networking infrastructure.
#
module "deploy_vpc" {
  source = "./vpc"
  #  region   = "eu-west-1"
  #  vpc_cidr = "192.168.0.0/16"
}
