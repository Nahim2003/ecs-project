########################################
# Locals & Data
########################################

locals {
  name_prefix    = "${var.project}-${var.env}"
  container_name = "${var.project}-app"
}

# Helpful for awslogs region without adding a new var
data "aws_region" "current" {}

# Derive VPC ID from first private subnet (avoids adding a vpc_id var)
data "aws_subnet" "first_private" {
  id = var.private_subnet_ids[0]
}

########################################
# ECS Cluster
########################################
resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cluster"
  })
}

########################################
# CloudWatch Logs
########################################
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "/ecs/${local.name_prefix}"
  })
}

########################################
# IAM Roles
########################################
# Execution role (pull image, push logs)
resource "aws_iam_role" "execution" {
  name = "${local.name_prefix}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-exec-role"
  })
}

resource "aws_iam_role_policy_attachment" "execution_basic" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role (your app’s AWS permissions; empty for now)
resource "aws_iam_role" "task" {
  name = "${local.name_prefix}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-task-role"
  })
}

########################################
# Service Security Group
########################################
resource "aws_security_group" "service" {
  name        = "${local.name_prefix}-svc-sg"
  description = "Allow ALB to app on container port" # ASCII-only
  vpc_id      = data.aws_subnet.first_private.vpc_id

  # Ingress from ALB SG only
  ingress {
    description     = "ALB to app"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Egress anywhere (NAT handles outbound)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-svc-sg"
  })
}

########################################
# Task Definition (Fargate)
########################################
resource "aws_ecs_task_definition" "this" {
  family                   = "${local.name_prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name  = local.container_name
      image = "${var.container_image}:${var.image_tag}"
      essential = true

      portMappings = [{
        containerPort = var.container_port
        protocol      = "tcp"
      }]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "PORT",     value = tostring(var.container_port) }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-task"
  })
}

########################################
# ECS Service (Fargate)
########################################
resource "aws_ecs_service" "this" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  enable_execute_command = false

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = local.container_name   # must exactly match task def
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 45

  lifecycle {
    ignore_changes = [desired_count] # optional: for autoscaling later
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-service"
  })
}
