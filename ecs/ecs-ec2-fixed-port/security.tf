###################################################################################################
########  Setting UP Security Groups  ########
###################################################################################################
resource "aws_security_group" "permit_internal" {
  name        = join("-", ["${local.prj_full_name}", "permit-all"])
  description = "permit all within vpc"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.security_tag,
    {
      uid  = var.prj_id
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
########################################## IAM ROLE ##########################################
###################################################################################################
resource "aws_iam_role" "ecs_role" {
  name = "ecs_ec2_ssm"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.policy_role_tag,
    var.security_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "ECS_IAM_Role"])
      Type = "Role"
    }
  )
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = join("-", ["${local.prj_full_name}", "ecs-ec2-ssm-role"])
  role = aws_iam_role.ecs_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachments_ecs" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = var.iam_roles["ecs"]
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachments_ssm" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = var.iam_roles["ssm"]
}
