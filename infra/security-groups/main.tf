variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "public_subnet_cidr_block" {}
variable "app_port" {
  description = "The port the Python API application runs on (e.g., 5000 or 8080)."
  type        = number
}

output "sg_ec2_sg_ssh_http_id" {
  value = aws_security_group.ec2_sg_ssh_http.id
}

output "sg_rds_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds_mysql_sg.id
}

output "rds_mysql_sg_id" {
  description = "Security group ID for RDS (legacy output name)"
  value       = aws_security_group.rds_mysql_sg.id
}

output "sg_alb_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

# Security Group for ALB - HTTP (80) from anywhere
resource "aws_security_group" "alb_sg" {
  name        = "${var.ec2_sg_name}-alb"
  description = "Allow HTTP (80) to ALB from anywhere"
  vpc_id      = var.vpc_id

  # HTTP for public access
  ingress {
    description = "Allow HTTP from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # Outbound traffic: Allow all outbound requests
  egress {
    description = "Allow outgoing requests"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}

# Security Group for EC2 - SSH (22) and Application Port (e.g., 5000)
resource "aws_security_group" "ec2_sg_ssh_http" {
  name        = var.ec2_sg_name
  description = "Allow SSH (22) and Application Port (${var.app_port}) to EC2 from anywhere"
  vpc_id      = var.vpc_id

  # SSH for remote access
  ingress {
    description = "Allow remote SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # Application Port (e.g., 5000) for direct public access
  ingress {
    description = "Allow traffic to the application port from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
  }

  # Removed: Ingress rule for HTTP (80)
  # Removed: Ingress rule for HTTPS (443)

  # Outbound traffic: Allow all outbound requests
  egress {
    description = "Allow outgoing requests"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2 SG to allow SSH and App Port"
  }
}

# Security Group for RDS MySQL - Allow access from EC2 instances only
resource "aws_security_group" "rds_mysql_sg" {
  name        = "rds-sg"
  description = "Allow access to RDS from EC2 instances"
  vpc_id      = var.vpc_id

  # Only allow EC2 instances to connect to MySQL (port 3306)
  ingress {
    from_port             = 3306
    to_port               = 3306
    protocol              = "tcp"
    # This correctly references the EC2 Security Group ID
    security_groups       = [aws_security_group.ec2_sg_ssh_http.id]
  }

  # Outbound traffic: Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS SG to allow MySQL access from EC2"
  }
}