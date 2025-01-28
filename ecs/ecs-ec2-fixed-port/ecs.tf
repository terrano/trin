###################################################################################################
########  Setting UP ECS Cluster  ########
###################################################################################################
resource "aws_ecs_cluster" "fargate_cluster" {
  name = var.ecs_cluster_name

  tags = merge(
    var.ecs_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "ECS_Cluster"])
      Type = "ECS"
    }
  )
}

###################################################################################################
########  Setting UP Capacity Provider  ########
###################################################################################################
resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name = join("-", ["${local.prj_full_name}", "ec2_capacity_provider"])

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.spc_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_provider_grp" {
  cluster_name = aws_ecs_cluster.fargate_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ec2_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider.name
  }
}

###################################################################################################
########  Setting UP Task Definitioin  ########
###################################################################################################
data "aws_ecs_task_definition" "spc_task_ec2" {
  task_definition = "arn:aws:ecs:us-east-2:779846826293:task-definition/spc-task:4"
}

###################################################################################################
########  Setting UP ECS Service  ########
###################################################################################################
resource "aws_ecs_service" "ec2_service" {
  name            = join("-", ["${local.prj_full_name}", "ecs-ec2"])
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = data.aws_ecs_task_definition.spc_task_ec2.arn
  launch_type     = "EC2"

  desired_count = 1

  deployment_controller {
    type = "ECS"
  }
}