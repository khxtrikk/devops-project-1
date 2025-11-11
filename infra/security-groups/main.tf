variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "public_subnet_cidr_block" {}
variable "ec2_sg_name_for_python_api" {}

output "sg_ec2_sg_ssh_http_id" {
  value = aws_security_group.ec2_sg_ssh_http.id
}

output "rds_mysql_sg_id" {
  value = aws_security_group.rds_mysql_sg.id
}

output "sg_ec2_for_python_api" {
  value = aws_security_group.ec2_sg_python_api.id
}

# Security Group for EC2 - SSH (22), HTTP (80), HTTPS (443)
resource "aws_security_group" "ec2_sg_ssh_http" {
  name        = var.ec2_sg_name
  description = "Allow SSH (22), HTTP (80), and HTTPS (443) to EC2"
  vpc_id      = var.vpc_id

  # SSH for remote access
  ingress {
    description = "Allow remote SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # HTTP traffic
  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # HTTPS traffic
  ingress {
    description = "Allow HTTPS request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
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
    Name = "EC2 SG to allow SSH(22), HTTP(80), and HTTPS(443)"
  }
}

# Security Group for RDS MySQL - Allow access from EC2 instances only
resource "aws_security_group" "rds_mysql_sg" {
  name        = "rds-sg"
  description = "Allow access to RDS from EC2 instances"
  vpc_id      = var.vpc_id

  # Only allow EC2 instances to connect to MySQL (port 3306)
  ingress {
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_groups          = [aws_security_group.ec2_sg_ssh_http.id]
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

# Security Group for Python API - Allow traffic on port 5000 from ALB only
resource "aws_security_group" "ec2_sg_python_api" {
  name        = var.ec2_sg_name_for_python_api
  description = "Allow traffic on port 5000 for Python API"
  vpc_id      = var.vpc_id

  # Allow traffic from the load balancer (ALB)
  ingress {
    description = "Allow traffic on port 5000 from ALB only"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    security_groups = [aws_security_group.dev_proj_1_lb.id]  # Assuming ALB security group is named "dev_proj_1_lb"
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
    Name = "EC2 SG for Python API on port 5000"
  }
}
