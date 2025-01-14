###################################################################################################
########################################## SSM ROLE ##########################################
###################################################################################################
resource "aws_iam_role" "ec2_role" {
  name = join("-", ["${local.prj_full_name}", "EC2_IAM_Role"])

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
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "EC2_IAM_Role"])
      Type = "Role"
    }
  )
}

resource "aws_iam_policy" "get_image" {
  name = join("-", ["${local.prj_full_name}", "get-image-ecr"])

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ecr:GetAuthorizationToken",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Resource" : local.docker_image_arn
      }
    ]
  })

  tags = merge(
    var.policy_role_tag,
    var.security_tag,
    {
      uid = var.prj_id
      Name =  join("-", ["${local.prj_full_name}", "get-image-ecr"])
      Type = "Policy"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachments_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ssm_policy_arn
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachments_ecr" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.get_image.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name =  join("-", ["${local.prj_full_name}", "ssm-ec2-role"])
  role = aws_iam_role.ec2_role.name
}

###################################################################################################
########################################### SSM ENDPOINTS #########################################
###################################################################################################
resource "aws_vpc_endpoint" "ssm" {
#  for_each          = toset(["com.amazonaws.us-east-2.ssm", "com.amazonaws.us-east-2.ssmmessages", "com.amazonaws.us-east-2.ec2messages"])
  for_each          = var.region_config["${var.region}"].ssm_endpoints
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["private_a"].id, aws_subnet.subnets["private_b"].id
  ]

  security_group_ids = [aws_security_group.permit_internal.id]

  private_dns_enabled = true

  tags = merge(
    var.policy_role_tag,
    var.network_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "SSM_Communication"])
      Type = "Endpoint"
    }
  )
}

###################################################################################################
########################################### ECR ENDPOINTS #########################################
###################################################################################################
resource "aws_vpc_endpoint" "ecr_api" {
#  for_each          = toset(["com.amazonaws.us-east-2.ecr.api", "com.amazonaws.us-east-2.ecr.dkr"])
  for_each          = var.region_config["${var.region}"].ecr_endpoints
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["private_a"].id, aws_subnet.subnets["private_b"].id
  ]

  security_group_ids = [aws_security_group.permit_internal.id]

  private_dns_enabled = true

  tags = merge(
    var.policy_role_tag,
    var.network_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "ECR_Communication"])
      Type = "Endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "ecr_s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = var.region_config["${var.region}"].ecr_s3_endpoint
  vpc_endpoint_type = "Gateway"

  private_dns_enabled = false

  tags = merge(
    var.policy_role_tag,
    var.network_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "S3_Communication"])
      Type = "Endpoint"
    }
  )
}

resource "aws_vpc_endpoint_route_table_association" "ecr_s3_rt" {
  route_table_id  = aws_route_table.private_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.ecr_s3.id
}

###################################################################################################
############################################# INSTANCES ###########################################
###################################################################################################
resource "aws_instance" "first" {
  ami                    = local.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_rules.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = aws_subnet.subnets["private_a"].id

  tags = merge(
    var.ec2_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "WEB-A"])
      Type = "EC2"
    }
  )

  user_data = var.python_web_server

  depends_on = [aws_iam_instance_profile.ec2_instance_profile]
}

resource "aws_instance" "second" {
  ami                    = local.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_rules.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = aws_subnet.subnets["private_b"].id

  tags = merge(
    var.ec2_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "WEB-B"])
      Type = "EC2"
    }
  )

  user_data = var.python_web_server

  depends_on = [aws_iam_instance_profile.ec2_instance_profile]
}

###################################################################################################
########################################## LOAD BALANCER ##########################################
###################################################################################################
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 8888
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }

  tags = merge(
    var.network_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "front_end"])
      Type = "LB-FrontEnd"
    }
  )
}

resource "aws_lb_target_group" "tg_instnaces" {
  name     = join("-", ["${local.prj_full_name}", "tg"])
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    var.network_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "target-group"])
      Type = "TargetGroup"
    }
  )
}

resource "aws_lb_target_group_attachment" "instance_vm1" {
  target_group_arn = aws_lb_target_group.tg_instnaces.arn
  target_id        = aws_instance.first.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_vm2" {
  target_group_arn = aws_lb_target_group.tg_instnaces.arn
  target_id        = aws_instance.second.id
  port             = 8080
}

resource "aws_lb_listener_rule" "listener_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_instnaces.arn
  }

  tags = merge(
    var.network_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "load-balancer", "listener"])
      Type = "LoadBalancerListener"
    }
  )
}

resource "aws_lb" "load_balancer" {
  name               = join("-", ["${local.prj_full_name}", "lb"])
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id]
  security_groups    = [aws_security_group.lb_rules.id]

  tags = merge(
    var.network_tag,
    {
      uid = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "load-balancer"])
      Type = "LoadBalancer"
    }
  )
}
