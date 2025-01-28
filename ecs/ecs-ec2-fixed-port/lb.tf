###################################################################################################
########################################## LOAD BALANCER ##########################################
###################################################################################################
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

  tags = merge(
    var.network_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "front_end"])
      Type = "LB-FrontEnd"
    }
  )
}

resource "aws_lb_target_group" "tg_asg" {
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
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "target-group"])
      Type = "TargetGroup"
    }
  )
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
    target_group_arn = aws_lb_target_group.tg_asg.arn
  }

  tags = merge(
    var.network_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "load-balancer", "listener"])
      Type = "LoadBalancerListener"
    }
  )
}

resource "aws_lb" "load_balancer" {
  name               = join("-", ["${local.prj_full_name}", "lb"])
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id]
  security_groups    = [aws_security_group.permit_internal.id]

  tags = merge(
    var.network_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "load-balancer"])
      Type = "LoadBalancer"
    }
  )
}
