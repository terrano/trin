variable "region" {
  type    = string
  default = "us-east-1"
}

variable "foundation_model" {
  type    = string
  default = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
}

variable "bedrock_knowledgebase_role" {
  type    = string
  default = "bedrock_knowledgebase_role"
}

variable "bedrock_fm_policy_name" {
  type    = string
  default = "bedrock_fm_policy_FM_Policy"
}

variable "bedrock_rds_policy_name" {
  type    = string
  default = "bedrock_rds_policy"
}

variable "bedrock_s3_policy_name" {
  type    = string
  default = "bedrock_s3_policy"
}

variable "bedrock_secrets_policy" {
  type    = string
  default = "bedrock_secrets_policy_name"
}

variable "secret_manager_key_name" {
  type    = string
  default = "rds/admin"
}

variable "s3_bucket_knowledgebase_name" {
  type    = string
  default = "trinity-knowledgebase-ingress"
}

variable "s3_bedrock_datasource" {
  type    = string
  default = "trinity-s3-data-source"
}

variable "aurora_cluster_name" {
  type    = string
  default = "trinity-poc-cluster"
}

variable "credential_encryption_key_alias" {
  type    = string
  default = "alias/credential_encryption"
}