###################################################################################################
########  Setting UP Network ACL's  ########
###################################################################################################

########  Public NACL  ########
resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.subnets["public_rds_a"].id, aws_subnet.subnets["public_rds_b"].id]

  egress {
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = var.default
    action     = "allow"
  }

  ingress {
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = var.default
    action     = "allow"
  }

  tags = {
    Name = "public_nacl"
  }

  depends_on = [aws_vpc.main]
}

########  Private NACL  ########
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id

  egress {
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = var.default
    action     = "allow"
  }

  ingress {
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = var.default
    action     = "allow"
  }

  tags = {
    Name = "private_nacl"
  }

  depends_on = [aws_vpc.main]
}

########  Inner NACL  ########
resource "aws_network_acl" "inner_nacl" {
  vpc_id = aws_vpc.main.id

  egress {
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = var.default
    action     = "allow"
  }

  ingress {
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = var.default
    action     = "allow"
  }

  tags = {
    Name = "inner_nacl"
  }

  depends_on = [aws_vpc.main]
}

###################################################################################################
########  Setting UP Security Groups  ########
###################################################################################################

resource "aws_security_group" "ec2-rds-1" {
  name        = "ec2-rds-1"
  description = "Security group attached to trinity-database-cluster to allow EC2 instances with specific security groups attached to connect to the database. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.default}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default}"]
  }

  tags = {
    Name = "ec2-rds-1"
  }
}

resource "aws_security_group" "rds-ec2-1" {
  name        = "rds-ec2-1"
  description = "Security group attached to instances to securely connect to trinity-poc-cluster. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.default}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default}"]
  }

  tags = {
    Name = "rds-ec2-1"
  }
}

resource "aws_security_group" "ec2-rds-2" {
  name        = "ec2-rds-2"
  description = "Security group attached to instances to securely connect to trinity-poc-cluster. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.default}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default}"]
  }

  tags = {
    Name = "ec2-rds-2"
  }
}

resource "aws_security_group" "rds-ec2-2" {
  name        = "rds-ec2-2"
  description = "Security group attached to trinity-poc-cluster to allow EC2 instances with specific security groups attached to connect to the database. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.default}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default}"]
  }

  tags = {
    Name = "rds-ec2-2"
  }
}

resource "aws_security_group" "llm-bastion-security-group" {
  name   = "llm-bastion-security-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.default}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default}"]
  }

  tags = {
    Name = "llm-bastion-security-group"
  }
}