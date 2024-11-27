###################################################################################################
############################################ AURORA DB ############################################
###################################################################################################

terraform {
  # For RDS Cluster with Aurora DB serverlessv2 configuration
  # aws provider version 4.15.0 or higher is needed
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.15.0"
    }
  }
}

########  Obtaining VPC ID  ########
data "aws_vpc" "main_vpc_id" {
  filter {
    name   = "tag:name"
    values = ["Main_VPC"]
  }
}

########  Obtaining Subnet ID's  ########
data "aws_subnets" "subnet_ids" {
  filter {
    name   = "tag:Name"
    values = ["RDS-Inner*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc_id.id]
  }

  depends_on = [data.aws_vpc.main_vpc_id]
}

########  Obtaining Security Group ID  ########
data "aws_security_group" "security_group_ids" {
  filter {
    name   = "tag:Name"
    values = ["ec2-rds-2"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main_vpc_id.id]
  }

  depends_on = [data.aws_vpc.main_vpc_id]
}

########  Obtaining Credentials Reference  ########
data "aws_secretsmanager_secret" "rds_admin_credentials" {
  name = var.secret_manager_key_name
}

data "aws_secretsmanager_secret_version" "rds_admin_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.rds_admin_credentials.id
}

########  Obtaining KMS Reference  ########
data "aws_kms_key" "credential_encryption_key" {
  key_id = var.credential_encryption_key_alias
}

########  Setting UP IAM Monitoring Role  ########
resource "aws_iam_role" "aws_rds_monitoring_role" {
  name = "aws_rds_monitoring_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

########  Attaching IAM Monitoring Policy to IAM Monitoring Role ########
resource "aws_iam_role_policy_attachment" "aws_rds_monitoring_policy" {
  role       = aws_iam_role.aws_rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"

  depends_on = [aws_iam_role.aws_rds_monitoring_role]
}

########  Setting UP SubnetGroup  ########
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = data.aws_subnets.subnet_ids.ids
}

########  Cluster Itself  ########
resource "aws_rds_cluster" "main" {
  cluster_identifier   = var.aurora_cluster_name
  database_name        = var.aurora_db_name
  engine               = "aurora-postgresql"
  engine_version       = "16.1"
  port                 = 5432
  enable_http_endpoint = true
  availability_zones   = [local.region_a, local.region_b]

  master_username = jsondecode(data.aws_secretsmanager_secret_version.rds_admin_credentials_version.secret_string)["username"]
  master_password = jsondecode(data.aws_secretsmanager_secret_version.rds_admin_credentials_version.secret_string)["password"]
  kms_key_id      = data.aws_kms_key.credential_encryption_key.arn

  storage_encrypted = true

  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.id
  backup_retention_period      = 5
  preferred_backup_window      = "03:21-03:51"
  preferred_maintenance_window = "wed:08:07-wed:08:37"
  vpc_security_group_ids       = [data.aws_security_group.security_group_ids.id]


  skip_final_snapshot = true

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 16.0
  }

  tags = {
    Project = "Trinity"
  }

  depends_on = [aws_db_subnet_group.db_subnet_group]
}

########  Cluster Instance  ########
resource "aws_rds_cluster_instance" "instance-1" {
  count               = 1
  identifier          = "${var.aurora_cluster_name}-instance-1"
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.main.engine
  engine_version      = aws_rds_cluster.main.engine_version
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.aws_rds_monitoring_role.arn


  depends_on = [aws_rds_cluster.main]
}

########  Cluster Endpoints  ########
#resource "aws_rds_cluster_endpoint" "read" {
#  cluster_identifier          = aws_rds_cluster.main.id
#  cluster_endpoint_identifier = "reader"
#  custom_endpoint_type        = "READER"

#  depends_on = [aws_rds_cluster.main]
#}

#resource "aws_rds_cluster_endpoint" "write" {
#  cluster_identifier          = aws_rds_cluster.main.id
#  cluster_endpoint_identifier = "writer"
#  custom_endpoint_type        = "ANY"

#  depends_on = [aws_rds_cluster.main]
#}