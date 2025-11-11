variable "db_subnet_group_name" {}
variable "subnet_groups" {}             # private subnet IDs
variable "rds_mysql_sg_id" {}          # RDS security group ID
variable "mysql_db_identifier" {}
variable "mysql_username" {}
variable "mysql_password" {}
variable "mysql_dbname" {}

# RDS Subnet Group (private subnets)
resource "aws_db_subnet_group" "dev_proj_1_db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_groups

  tags = {
    Name = "dev-proj-1-db-subnet-group"
  }
}

# RDS Security Group (allow EC2 access)
resource "aws_security_group_rule" "allow_ec2_to_rds" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = var.rds_mysql_sg_id
  source_security_group_id = var.rds_mysql_sg_id  # <-- Replace with your EC2 SG if different
}

# MySQL RDS instance
resource "aws_db_instance" "dev_proj_1_rds" {
  allocated_storage       = 10
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  identifier              = var.mysql_db_identifier
  username                = var.mysql_username
  password                = var.mysql_password
  db_name                 = var.mysql_dbname

  vpc_security_group_ids  = [var.rds_mysql_sg_id]
  db_subnet_group_name    = aws_db_subnet_group.dev_proj_1_db_subnet_group.name

  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 0
  deletion_protection     = false

  publicly_accessible     = false  # Important: keep it private
}

# Outputs
output "dev_proj_1_rds_endpoint" {
  value = aws_db_instance.dev_proj_1_rds.endpoint
}

output "dev_proj_1_rds_instance_id" {
  value = aws_db_instance.dev_proj_1_rds.id
}
