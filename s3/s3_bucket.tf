###################################################################################################
############################################ S3 BUCKET ############################################
###################################################################################################
resource "aws_s3_bucket" "s3_bucket_knowledgebase" {
  bucket        = var.s3_bucket_knowledgebase_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.s3_bucket_knowledgebase.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_encryption" {
  bucket = aws_s3_bucket.s3_bucket_knowledgebase.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
