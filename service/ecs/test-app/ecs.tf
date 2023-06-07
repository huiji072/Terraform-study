# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${local.prefix}-${local.suffix}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Fargate Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${local.prefix}-${local.suffix}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name  = "${local.prefix}-${local.suffix}"
    image = "${aws_ecr_repository.example.repository_url}:${local.ecr_repository_tag}"

    essential = true

    portMappings = [
      {
        containerPort = 80
      }
    ]
  }])
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = "${local.prefix}-${local.suffix}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = [var.public_subnet_ids[0], var.public_subnet_ids[1]]

    security_groups = [
      aws_security_group.sg-test-app.id
    ]

    assign_public_ip = true
  }

    load_balancer {
    target_group_arn = aws_lb_target_group.tg-test-app.arn
    container_name   = "${local.prefix}-${local.suffix}"
    container_port   = 80
  }
    depends_on = [aws_lb_listener.lb-listener-test-app]

}

# IAM Role
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecsExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment_ecs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}