resource "aws_ecs_cluster" "centos" {
  name               = "centos"
  capacity_providers = ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_task_definition" "centos" {
  family             = "centos"
  cpu                = 1024
  memory             = 2048
  container_definitions = jsonencode([
    {
      name      = "centos"
      image     = "centos:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "centos" {
  name            = "centos"
  depends_on      = ["aws_ecs_task_definition.centos"]
  cluster         = aws_ecs_cluster.centos.id
  task_definition = aws_ecs_task_definition.centos.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets = var.subnets
  }
}
