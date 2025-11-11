# EC2 Module Variables
variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The subnet ID where the instance will be launched"
  type        = string
}

variable "key_name" {
  description = "The name of the EC2 key pair"
  type        = string
}

variable "ec2_security_groups" {
  description = "List of security group IDs for the EC2 instance"
  type        = list(string)
}

variable "user_data" {
  description = "User data script for the EC2 instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the EC2 instance"
  type        = map(string)
  default     = {}
}

# EC2 Instance Resource
resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.ec2_security_groups
  user_data                   = var.user_data
  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = lookup(var.tags, "Name", "app-server")
    }
  )
}

# --- Outputs ---

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "ec2_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "ssh_connection_string_for_ec2" {
  description = "SSH connection string for the EC2 instance"
  value       = "ssh -i /path/to/key.pem ec2-user@${aws_instance.app_server.public_ip}"
}