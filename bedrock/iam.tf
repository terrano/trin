###################################################################################################
#################################### IAM POLICIES FOR BEDROCK #####################################
###################################################################################################

######## Obtaining refrences  ########
data "aws_caller_identity" "this" {}
data "aws_s3_bucket" "s3_knowledgebase" {
  bucket = var.s3_bucket_knowledgebase_name
}
data "aws_secretsmanager_secret" "rds_admin_credentials" {
  name = var.secret_manager_key_name
}

########  Setting UP Role For KnowledgeBase  ########
resource "aws_iam_role" "bedrock_knowledgebase_role" {
  name = "${var.knowledge_name}_Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "bedrock.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

########  Setting UP Policy For Foundation Model  ########
resource "aws_iam_policy" "bedrock_fm_policy" {
  name = "${var.knowledge_name}_FM_Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel"
        ],
        "Resource" : [
          "arn:aws:bedrock:${var.region}::foundation-model/cohere.embed-english-v3",
          "arn:aws:bedrock:${var.region}::foundation-model/amazon.titan-embed-text-v1"
        ]
      }
    ]
  })
}

########  Setting UP Policy For RDS  ########
resource "aws_iam_policy" "bedrock_rds_policy" {
  name = "${var.knowledge_name}_RDS_Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "RdsDescribeStatementID",
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBClusters"
        ],
        "Resource" : [
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.this.account_id}:cluster:${var.aurora_cluster_name}"
        ]
      },
      {
        "Sid" : "DataAPIStatementID",
        "Effect" : "Allow",
        "Action" : [
          "rds-data:BatchExecuteStatement",
          "rds-data:ExecuteStatement"
        ],
        "Resource" : [
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.this.account_id}:cluster:${var.aurora_cluster_name}"
        ]
      }
    ]
  })
}

########  Setting UP Policy For S3  ########    
resource "aws_iam_policy" "bedrock_s3_policy" {
  name = "${var.knowledge_name}_S3_Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3ListBucketStatement",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "${data.aws_s3_bucket.s3_knowledgebase.arn}"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : [
              "${data.aws_caller_identity.this.account_id}"
            ]
          }
        }
      },
      {
        "Sid" : "S3GetObjectStatement",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "${data.aws_s3_bucket.s3_knowledgebase.arn}/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceAccount" : [
              "${data.aws_caller_identity.this.account_id}"
            ]
          }
        }
      }
    ]
  })
}

########  Setting UP Policy For Secrets  ########
resource "aws_iam_policy" "bedrock_secrets_policy" {
  name = "${var.knowledge_name}_Secrets_Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SecretsManagerGetStatement",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "${data.aws_secretsmanager_secret.rds_admin_credentials.id}"
            ]
        }
    ]
})
}

########  Attaching Policies to Role ########
resource "aws_iam_role_policy_attachment" "attach_bedrock_fm_policy" {
  role       = aws_iam_role.bedrock_knowledgebase_role.name
  policy_arn = aws_iam_policy.bedrock_fm_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_rds_policy" {
  role       = aws_iam_role.bedrock_knowledgebase_role.name
  policy_arn = aws_iam_policy.bedrock_rds_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_s3_policy" {
  role       = aws_iam_role.bedrock_knowledgebase_role.name
  policy_arn = aws_iam_policy.bedrock_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_secrets_policy" {
  role       = aws_iam_role.bedrock_knowledgebase_role.name
  policy_arn = aws_iam_policy.bedrock_secrets_policy.arn
}
