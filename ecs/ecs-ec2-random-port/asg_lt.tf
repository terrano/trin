###################################################################################################
########  Setting UP Launch Tamplate  ########
###################################################################################################
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}

resource "aws_launch_template" "spc_lt" {
  name = join("-", ["${local.prj_full_name}", "lt"])

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_profile.arn
  }

  image_id = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]

  instance_type = var.image_types["t2micro"]

  vpc_security_group_ids = [aws_security_group.permit_internal.id]

  user_data = base64encode(var.esc_agent_cluster_name)

  tags = merge(
    var.ecs_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "LaunchTemplate"])
      Type = "LaunchTemplate"
    }
  )
}

###################################################################################################
########  Setting UP AutScaling Group  ########
###################################################################################################
resource "aws_autoscaling_group" "spc_asg" {
  name = join("-", [local.prj_full_name, "asg"])

  desired_capacity = 0
  max_size         = 1
  min_size         = 0

  vpc_zone_identifier = [
    aws_subnet.subnets["public_a"].id,
    aws_subnet.subnets["public_b"].id
  ]

  capacity_rebalance = false
  default_cooldown   = 300

  health_check_grace_period = 0
  health_check_type         = "EC2"

  launch_template {
    id      = aws_launch_template.spc_lt.id
    version = tostring(aws_launch_template.spc_lt.latest_version)
  }

  tag {
    key                 = "uid"
    value               = var.prj_id
    propagate_at_launch = false
  }

  tag {
    key                 = "Name"
    value               = "${local.prj_full_name}-AutoScalingGroup"
    propagate_at_launch = false
  }

  tag {
    key                 = "Type"
    value               = "AutoScalingGroup"
    propagate_at_launch = false
  }
}
