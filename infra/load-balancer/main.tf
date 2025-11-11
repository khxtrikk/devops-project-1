# Variables for the Application Load Balancer
variable "load_balancer_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of Load Balancer (application or network)"
  type        = string
  default     = "application"
}

variable "internal" {
  description = "Whether the Load Balancer is internal or external"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnet IDs for the Load Balancer"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the Load Balancer"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the Load Balancer"
  type        = map(string)
  default     = {}
}

# Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.dev_proj_1_lb.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.dev_proj_1_lb.arn
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.dev_proj_1_lb.zone_id
}

# Application Load Balancer
resource "aws_lb" "dev_proj_1_lb" {
  name               = var.load_balancer_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = false

  tags = var.tags
}