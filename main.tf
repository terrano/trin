terraform {
  backend "s3" {
    bucket         = "bedrock-infrastructure"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
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
  region = "eu-west-1"
  #  vpc_cidr = "192.168.0.0/16"
}

#
#    Use this module to deploy KMS manager.
#
#module "deploy_kms" {
#  source                  = "./kms"
#  deletion_window_in_days = 7
#}

#
#    Use this module to deploy S3 Bucket.
#
module "deploy_s3_bucket" {
  source                       = "./s3"
  s3_bucket_knowleagebase_name = "trinity-knowleadgebase"
}

#
#    Use this module to deploy RDS Aurora
#
module "deploy_aurora" {
  source                       = "./aurora"
  region                       = "eu-west-1"
  s3_bucket_knowleagebase_name = "trinity-knowleadgebase"

  depends_on = [module.deploy_vpc]
  #  depends_on = [module.deploy_kms]
}
