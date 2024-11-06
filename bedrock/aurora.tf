###################################################################################################
############################################ AURORA DB ############################################
###################################################################################################

########  Obtaining VPC ID  ########
data "aws_vpc" "main_vpc_id" {
  filter {
    name   = "tag:name"
    values = ["Main_VPC"]
  }
}

########  Obtaining Subnet ID's  ########
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.main_vpc_id.id
  filter {
    name   = "tag:Name"
    values = ["RDS-Inner*"]
  }

  depends_on = [ data.aws_vpc.main_vpc_id ]
}

########  Setting UP SubnetGroup  ########
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = data.aws_subnet_ids.subnet_ids.ids
}

########  Cluster Itself  ########
resource "aws_rds_cluster" "main" {
  cluster_identifier           = var.aurora_cluster_name
  engine                       = "aurora-postgresql"
  engine_version               = "16.1"
  port                         = 5432
  availability_zones           = [local.region_a, local.region_b]
  database_name                = var.aurora_cluster_name
  master_username              = var.db_credentials["master_username"]
  master_password              = var.db_credentials["master_password"]
  db_subnet_group_name         = aws_db_subnet_group.db_subnet_group.id
  backup_retention_period      = 5
  preferred_backup_window      = "03:21-03:51"
  preferred_maintenance_window = "wed:08:07-wed:08:37"

  depends_on = [ aws_db_subnet_group.db_subnet_group ]
}

########  Cluster Instance  ########
resource "aws_rds_cluster_instance" "instance-1" {
  count              = 1
  identifier         = "${var.aurora_cluster_name}-instance-1"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  depends_on = [ aws_rds_cluster.main ]
}

########  Cluster Endpoints  ########
resource "aws_rds_cluster_endpoint" "read" {
  cluster_identifier          = aws_rds_cluster.main.id
  cluster_endpoint_identifier = "reader"
  custom_endpoint_type        = "READER"

  depends_on = [ aws_rds_cluster.main ]
}

resource "aws_rds_cluster_endpoint" "write" {
  cluster_identifier          = aws_rds_cluster.main.id
  cluster_endpoint_identifier = "writer"
  custom_endpoint_type        = "ANY"

  depends_on = [ aws_rds_cluster.main ]
}