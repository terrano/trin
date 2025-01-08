###################################################################################################
########################################## SSM ROLE ##########################################
###################################################################################################
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

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
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachments" {
  for_each   = toset([var.ssm_policy_arn, var.ecr_policy_arn])
  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ssm-ec2-role"
  role = aws_iam_role.ec2_role.name
}

###################################################################################################
########################################### SSM ENDPOINTS #########################################
###################################################################################################
resource "aws_vpc_endpoint" "ssm" {
  for_each          = toset(["com.amazonaws.us-east-2.ssm", "com.amazonaws.us-east-2.ssmmessages", "com.amazonaws.us-east-2.ec2messages"])
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["private_a"].id, aws_subnet.subnets["private_b"].id
  ]

  security_group_ids = [aws_security_group.permit_all.id]

  private_dns_enabled = true
}

###################################################################################################
########################################### ECR ENDPOINTS #########################################
###################################################################################################
resource "aws_vpc_endpoint" "ecr_api" {
  for_each          = toset(["com.amazonaws.us-east-2.ecr.api", "com.amazonaws.us-east-2.ecr.dkr"])
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["private_a"].id, aws_subnet.subnets["private_b"].id
  ]

  security_group_ids = [aws_security_group.permit_all.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.s3"
  vpc_endpoint_type = "Gateway"

  private_dns_enabled = false
}

resource "aws_vpc_endpoint_route_table_association" "ecr_s3_rt" {
  route_table_id  = aws_route_table.private_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.ecr_s3.id
}

###################################################################################################
############################################# INSTANCES ###########################################
###################################################################################################
resource "aws_instance" "first" {
  ami                    = var.ohio_ec2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = aws_subnet.subnets["private_a"].id

  #user_data = var.python_web_server

  tags = {
    Name = "WEB-A"
  }

  depends_on = [aws_iam_instance_profile.ec2_instance_profile]
}

resource "aws_instance" "second" {
  ami                    = var.ohio_ec2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = aws_subnet.subnets["private_b"].id

  #user_data = var.python_web_server

  tags = {
    Name = "WEB-B"
  }

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
}

resource "aws_lb_target_group" "tg_instnaces" {
  name     = "petclinic-tg"
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
}

resource "aws_lb" "load_balancer" {
  name               = "spring-petclinic-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id]
  security_groups    = [aws_security_group.lb_rules.id]
}
