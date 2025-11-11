# RDS Module Variables
variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_instance_identifier" {
  description = "The identifier for the database instance"
  type        = string
}

variable "db_instance_class" {
  description = "The database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "db_private_subnets" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the RDS instance"
  type        = list(string)
}

variable "db_publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip the final snapshot"
  type        = bool
  default     = true
}

variable "db_storage_type" {
  description = "The storage type (gp2, io1, etc.)"
  type        = string
  default     = "gp2"
}

variable "db_allocated_storage" {
  description = "The allocated storage size in GB"
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "The database engine (mysql, postgres, etc.)"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The database engine version"
  type        = string
  default     = "8.0"
}

variable "db_port" {
  description = "The database port"
  type        = number
  default     = 3306
}

variable "db_username" {
  description = "The master username for the database"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the RDS instance"
  type        = map(string)
  default     = {}
}

# RDS Subnet Group (for private subnets)
resource "aws_db_subnet_group" "dev_proj_1_db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = length(var.db_private_subnets) > 0 ? var.db_private_subnets : []

  tags = {
    Name = "${var.db_subnet_group_name}-subnet-group"
  }
}

# MySQL RDS Instance
resource "aws_db_instance" "dev_proj_1_rds" {
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  identifier           = var.db_instance_identifier
  username             = var.db_username
  password             = var.db_password
  db_name              = var.db_name

  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.dev_proj_1_db_subnet_group.name

  skip_final_snapshot       = var.db_skip_final_snapshot
  apply_immediately         = true
  backup_retention_period   = 0
  deletion_protection       = false
  publicly_accessible       = var.db_publicly_accessible

  tags = merge(
    var.tags,
    {
      Name = var.db_instance_identifier
    }
  )
}

# Outputs
output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.dev_proj_1_rds.endpoint
}

output "db_instance_host" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.dev_proj_1_rds.address
}

output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.dev_proj_1_rds.id
}

output "db_instance_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.dev_proj_1_rds.port
}
