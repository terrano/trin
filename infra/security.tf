###################################################################################################
########  Setting UP Network ACL's  ########
###################################################################################################

########  Public NACL  ########
resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id]

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

###################################################################################################
########  Setting UP Security Groups  ########
###################################################################################################

resource "aws_security_group" "ec2" {
  name        = "ec2"
  description = "ec2 sg"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default}"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.default}"]
  }

  tags = {
    Name = "web-ec2-sg"
  }
}

