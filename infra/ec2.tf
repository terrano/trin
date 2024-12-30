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

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ssm_policy_arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ssm-ec2-role"
  role = aws_iam_role.ec2_role.name
}

###################################################################################################
########################################### SSM ENDPOINTS #########################################
###################################################################################################
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id
  ]

  security_group_ids = [aws_security_group.ec2.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id
  ]

  security_group_ids = [aws_security_group.ec2.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id
  ]

  security_group_ids = [aws_security_group.ec2.id]

  private_dns_enabled = true
}
###################################################################################################
############################################# INSTANCES ###########################################
###################################################################################################
resource "aws_instance" "first" {
  ami                    = var.ohio_ec2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = aws_subnet.subnets["public_a"].id

  user_data = var.python_web_server

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
  subnet_id              = aws_subnet.subnets["public_b"].id

  user_data = var.python_web_server

  tags = {
    Name = "WEB-B"
  }

  depends_on = [aws_iam_instance_profile.ec2_instance_profile]
}

###################################################################################################
########################################## LOAD BALANCER ##########################################
###################################################################################################
resource "aws_security_group" "lb_rules" {
  name        = "lb_communication_rules"
  description = "Control load balancer traffic"
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
    Name = "lb_sg"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
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
  name     = "tg"
  port     = 80
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
