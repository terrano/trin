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
resource "aws_security_group" "lb_rules" {
  name        = "lb_communication_rules"
  description = "Control load balancer traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.default]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [var.default]
  }

  tags = {
    Name = "lb_sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "ec2"
  description = "ec2 sg"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
      local.actual_subnets_data["public_a"].cidr_block,
      local.actual_subnets_data["public_b"].cidr_block
    ]
  }

  tags = {
    Name = "ec2_sg"
  }
}

resource "aws_security_group" "permit_all" {
  name        = "2-endpoints"
  description = "permit all for endpoints"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default]
  }

  tags = {
    Name = "permit_all"
  }
}