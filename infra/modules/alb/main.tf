variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

# Security group for the internet-facing ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-${var.env}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  # Allow HTTP + HTTPS from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Allow all egress (ALB to targets)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-alb-sg" })
}

# Internet-facing Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.project}-${var.env}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
security_groups    = [aws_security_group.alb_sg.id]
tags = merge(var.tags, { Name = "${var.project}-${var.env}-alb" })
}

# Target group for Fargate tasks (IP target type)
resource "aws_lb_target_group" "tg" {
  name        = "${var.project}-${var.env}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-tg" })
}

# Listener : 80 -> redirect to 443
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener : 443 terminates TLS and forwards to TG
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn   # ← use the input variable


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
