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
