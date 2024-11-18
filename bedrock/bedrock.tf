###################################################################################################
###################################### BEDROCK KNOWLEDGEBASE ######################################
###################################################################################################

data "aws_iam_role" "bedrock_knowledgebase_role" {
 name = "${var.knowledge_name}_Role"
}


#resource "aws_bedrockagent_knowledge_base" "base" {
#  name     = var.knowledge_name
#  role_arn = data.aws_iam_role.bedrock_knowledgebase_role.arn

# knowledge_base_configuration {
#    vector_knowledge_base_configuration {
#      embedding_model_arn = "arn:aws:bedrock:us-west-2::foundation-model/amazon.titan-embed-text-v1"
#    }
#    type = "VECTOR"
#  }

#  storage_configuration {
#    type = "OPENSEARCH_SERVERLESS"
#    opensearch_serverless_configuration {
#      collection_arn    = "arn:aws:aoss:us-west-2:123456789012:collection/142bezjddq707i5stcrf"
#      vector_index_name = "bedrock-knowledge-base-default-index"
#      field_mapping {
#        vector_field   = "bedrock-knowledge-base-default-vector"
#        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
#        metadata_field = "AMAZON_BEDROCK_METADATA"
#      }
#    }
#  }
#}