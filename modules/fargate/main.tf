resource "aws_ecs_cluster" "cloud_cluster" {
  name = "cloud-cluster"
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend-container"
      image     = "docker.io/kondapureddyumakk/capstone-frontend:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend-container"
      image     = "docker.io/kondapureddyumakk/capstone:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.cloud_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  load_balancer {
    target_group_arn = var.target_group_frontend_arn
    container_name   = "frontend-container"
    container_port   = 80
  }

  network_configuration {
    subnets         = [var.frontend_subnet1]
    security_groups = [aws_security_group.frontend_sg.id]
    assign_public_ip = false
  }

  }

resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.cloud_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  load_balancer {
    target_group_arn = var.target_group_backend_arn
    container_name   = "backend-container"
    container_port   = 5000
  }
  depends_on = [
    var.backend_listener_id,
    var.target_group_backend_arn]
  

  network_configuration {
    subnets         = [var.backend_subnet1]  # Ensure this is a list
    security_groups = [aws_security_group.backend_sg.id]
    assign_public_ip = false
  }
}



