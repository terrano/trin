###################################################################################################
###################################### BEDROCK KNOWLEDGEBASE ######################################
###################################################################################################

########  Obtaining S3 Reference  ########
data "aws_s3_bucket" "s3_bucket_knowledgebase" {
  bucket = var.s3_bucket_knowledgebase_name
}

########  Obtaining RDS DB Reference  ########
data "aws_rds_cluster" "main" {
  cluster_identifier = var.aurora_cluster_name
}

########  Setting UP Knowledgbase Itself  ########
resource "aws_bedrockagent_knowledge_base" "s3base" {
  name     = var.s3_bucket_knowledgebase_name
  role_arn = aws_iam_role.bedrock_knowledgebase_role.arn

  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = var.foundation_model
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "RDS"

    rds_configuration {
      credentials_secret_arn = data.aws_secretsmanager_secret.rds_admin_credentials.id
      database_name          = var.aurora_cluster_name
      table_name             = "rds_table_name"
      resource_arn           = data.aws_rds_cluster.main.arn
      field_mapping {
        primary_key_field = "id"
        text_field        = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field    = "AMAZON_BEDROCK_METADATA"
        vector_field      = "bedrock-knowledge-base-default-vector"
      }

    }
  }

  depends_on = [aws_iam_role.bedrock_knowledgebase_role]
}

resource "aws_bedrockagent_data_source" "s3_datasource" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.s3base.id
  name              = var.s3_bucket_knowledgebase_name
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = data.aws_s3_bucket.s3_bucket_knowledgebase.arn
    }
  }

  depends_on = [aws_bedrockagent_knowledge_base.s3base]
}
