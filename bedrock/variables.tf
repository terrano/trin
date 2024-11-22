variable "region" {
  type    = string
  default = "us-east-1"
}

variable "foundation_model" {
  type    = string
  default = "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v1"
}

variable "secret_manager_key_name" {
  type    = string
  default = "rds/admin"
}

variable "knowledge_name" {
  type    = string
  default = "trinity-knowledge-base"
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