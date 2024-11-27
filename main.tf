terraform {
  backend "s3" {
    bucket         = "bedrock-infrastructure-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"

  db_key_name                           = "TestAuroraDBEncyptionKey"
  credential_encryption_name            = "TestCredentialsEncyptionKey"
  db_key_description                    = "Test_RDS AuroraDB Encryption key"
  credential_encryption_key_description = "Test_RDS AuroraDB Credentials Encryption key"
  db_alias                              = "alias/test_rds_aurora_encryption"
  credential_encryption_key_alias       = "alias/test_rds_credential_encryption"

  secret_manager_key_name    = "rds/test_admin23"
  secret_manager_description = "Test_RDS Admin Credentials"

  s3_bucket_knowledgebase_name = "test-trinity-knowledgebase"

  aurora_db_name      = "test_auroradb"
  aurora_cluster_name = "test-trinity-poc-cluster"

  bedrock_knowledgebase_role = "test_bedrock_knowledgebase_role"
  bedrock_fm_policy_name     = "test_bedrock_fm_policy_FM_Policy"
  bedrock_rds_policy_name    = "test_bedrock_rds_policy"
  bedrock_s3_policy_name     = "test_bedrock_s3_policy"
  bedrock_secrets_policy     = "test_bedrock_secrets_policy"

  foundation_model = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
}

#
#    Use this module to deploy aws vpc networking infrastructure.
#
module "deploy_vpc" {
  source   = "./vpc"
  region   = local.region
  vpc_cidr = "192.168.0.0/16"
}

#
#    Use this module to deploy KMS manager.
#
module "deploy_security" {
  source                  = "./security"
  deletion_window_in_days = 7

  db_key_name                           = local.db_key_name
  credential_encryption_name            = local.credential_encryption_name
  db_key_description                    = local.db_key_description
  credential_encryption_key_description = local.credential_encryption_key_description
  db_alias                              = local.db_alias
  credential_encryption_key_alias       = local.credential_encryption_key_alias

  secret_manager_key_name    = local.secret_manager_key_name
  secret_manager_description = local.secret_manager_description


}

#
#    Use this module to deploy S3 Bucket.
#
module "deploy_s3_bucket" {
  source                       = "./s3"
  s3_bucket_knowledgebase_name = local.s3_bucket_knowledgebase_name
}

#
#    Use this module to deploy RDS Aurora
#
module "deploy_aurora" {
  source = "./aurora"
  region = local.region

  aurora_cluster_name = local.aurora_cluster_name
  aurora_db_name      = local.aurora_db_name

  secret_manager_key_name         = local.secret_manager_key_name
  credential_encryption_key_alias = local.credential_encryption_key_alias

  depends_on = [
    module.deploy_vpc,
    module.deploy_security
  ]
}

#
#    Use this module to deploy Custom Bedrock
#
module "deploy_knowledgebase" {
  source = "./bedrock"
  region = local.region

  s3_bucket_knowledgebase_name = local.s3_bucket_knowledgebase_name
  aurora_cluster_name          = local.aurora_cluster_name

  secret_manager_key_name         = local.secret_manager_key_name
  credential_encryption_key_alias = local.credential_encryption_key_alias

  bedrock_knowledgebase_role = local.bedrock_knowledgebase_role
  bedrock_fm_policy_name     = local.bedrock_fm_policy_name
  bedrock_rds_policy_name    = local.bedrock_rds_policy_name
  bedrock_s3_policy_name     = local.bedrock_s3_policy_name
  bedrock_secrets_policy     = local.bedrock_secrets_policy

  foundation_model = local.foundation_model

  depends_on = [module.deploy_s3_bucket, module.deploy_aurora, module.deploy_security]
}