# Variables for the Application Load Balancer Target Group
variable "vpc_id" {
  description = "VPC ID where the target group will be created"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol for the target group (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda, etc.)"
  type        = string
  default     = "instance"
}

variable "target_group_health_check" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "target_group_health_status" {
  description = "Expected health check response code"
  type        = string
  default     = "200"
}

variable "tags" {
  description = "Tags to apply to the target group"
  type        = map(string)
  default     = {}
}

# Outputs
output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.dev_proj_1_lb_target_group.arn
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.dev_proj_1_lb_target_group.id
}

# Load Balancer Target Group
resource "aws_lb_target_group" "dev_proj_1_lb_target_group" {
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = var.target_group_health_check
    port                = tostring(var.target_group_port)
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = var.target_group_health_status
  }

  tags = var.tags
}