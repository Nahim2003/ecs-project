# VPC ID so other modules (ALB/ECS) can reference it
output "vpc_id" {
  value = aws_vpc.main.id
}

# All public subnet IDs (one per AZ)
output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

# All private subnet IDs (one per AZ)
output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

