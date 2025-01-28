resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/spc-task"
  retention_in_days = 1

  tags = merge(
    var.logs,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "spc-task"])
      Type = "Logs"
    }
  )
}

