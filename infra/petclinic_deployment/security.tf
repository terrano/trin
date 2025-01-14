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

  tags = merge(
    var.security_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "public_nacl"])
      Type = "NetworkACL"
    }
  )

  depends_on = [aws_vpc.main]
}

###################################################################################################
########  Setting UP Security Groups  ########
###################################################################################################
resource "aws_security_group" "permit_internal" {
  name        =  join("-", ["${local.prj_full_name}", "permit-inside-all"])
  description = "permit all within vpc"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.security_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "inside_all_sg"])
      Type = "SecurityGroup"
    }
  )
}

resource "aws_security_group_rule" "permit_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.permit_internal.id
  cidr_blocks       = [var.default]
}

resource "aws_security_group_rule" "permit_engress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.permit_internal.id
  cidr_blocks       = [var.default]
}
###################################################################################################
resource "aws_security_group" "lb_rules" {
  name        = "lb_communication_rules"
  description = "Control load balancer traffic"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.security_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "LoadBalancerSG"])
      Type = "SecurityGroup"
    }
  )
}

resource "aws_security_group_rule" "lb_ingress" {
  type              = "ingress"
  from_port         = 8888
  to_port           = 8888
  protocol          = "tcp"
  security_group_id = aws_security_group.lb_rules.id
  cidr_blocks       = [var.default]
}

resource "aws_security_group_rule" "lb_egress" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_rules.id
  source_security_group_id = aws_security_group.ec2_rules.id
}

###################################################################################################
resource "aws_security_group" "ec2_rules" {
  name        = "ec2"
  description = "ec2 sg"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.security_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "EC2-SG-Rules"])
      Type = "SecurityGroup"
    }
  )
}

resource "aws_security_group_rule" "ec2_ingress" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_rules.id
  source_security_group_id = aws_security_group.lb_rules.id
}

resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2_rules.id
  cidr_blocks       = [var.default]
}
