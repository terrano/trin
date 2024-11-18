variable "region" {
  type    = string
  default = "us-east-1"
}

variable "knowledge_name" {
  type    = string
  default = "trinity-knowledge-base"
}

variable "s3_bucket_knowledgebase_name" {
  type    = string
  default = "trinity-knowledgebase-ingress"
}

variable "aurora_cluster_name" {
  type    = string
  default = "trinity-poc-cluster"
}

variable "secret_manager_key_name" {
  type    = string
  default = "rds/admin10"
}