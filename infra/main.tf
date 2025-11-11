# infra/main.tf (Updated)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops-project-1-tfstate-bucket"
    key            = "devops/project1/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "devops-project-1-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

# --- VPC & Networking Modules ---

module "networking" {
  source                = "./networking"
  vpc_name              = var.vpc_name
  vpc_cidr              = var.vpc_cidr
  cidr_public_subnet    = var.cidr_public_subnet
  cidr_private_subnet   = var.cidr_private_subnet
  eu_availability_zone  = var.eu_availability_zone
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

# --- Security Group Module ---

module "security_group" {
  source                   = "./security-groups"
  vpc_id                   = module.networking.vpc_id
  public_subnet_cidr_block = var.vpc_cidr 
  ec2_sg_name              = "webapp-ec2-sg"
  app_port                 = 8080 # Assuming port 8080
}

# --- Database (RDS) Module ---

module "rds_db_instance" {
  source                       = "./rds"
  db_name                      = "project1db"
  db_instance_identifier       = "project1db-instance"
  db_instance_class            = "db.t3.micro"
  db_password                  = "project1dbpassword"
  db_subnet_group_name         = module.networking.db_subnet_group_name
  vpc_security_group_ids       = [module.security_group.sg_rds_id]
  db_publicly_accessible       = false
  db_skip_final_snapshot       = true
  db_storage_type              = "gp2"
  db_allocated_storage         = 20
  db_engine                    = "mysql"
  db_engine_version            = "8.0"
  db_port                      = 3306
  db_username                  = "project1user"
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

# --- EC2 Module ---

module "ec2" {
  source                         = "./ec2"
  subnet_id                      = module.networking.public_subnets[0]
  key_name                       = var.public_key
  instance_type                  = "t2.micro"
  ami_id                         = var.ec2_ami_id
  ec2_security_groups            = [module.security_group.sg_ec2_sg_ssh_http_id] # FIX: Correct argument name for the EC2 module
  user_data                      = var.ec2_user_data_install_apache
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

# --- Load Balancer Module (Simplified) ---

# The original LB setup was for HTTPS (port 443) using ACM/Route53.
# We are switching to a simple HTTP ALB on port 80.

module "load-balancer" {
  source                = "./load-balancer"
  load_balancer_name    = var.name
  load_balancer_type    = "application"
  internal              = false
  subnets               = module.networking.public_subnets
  security_groups       = [module.security_group.sg_alb_id]
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

module "load-balancer-target-group" {
  source                     = "./load-balancer-target-group"
  vpc_id                     = module.networking.vpc_id
  target_group_name          = var.name
  target_group_port          = 8080 # The application port
  target_type                = "instance"
  target_group_protocol      = "HTTP"
  target_group_health_check  = "/"
  target_group_health_status = "200"
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

module "load-balancer-listener" {
  source                 = "./load-balancer-listener"
  load_balancer_arn      = module.load-balancer.load_balancer_arn
  target_group_arn       = module.load-balancer-target-group.target_group_arn
  listener_port          = 80 # ALB listener port (standard HTTP)
  listener_protocol      = "HTTP"
  default_action_type    = "forward"
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}


# --- Domain/SSL-Related Modules (REMOVED) ---
# Removed 'module "hosted-zone"'
# Removed 'module "certificate-manager"'
# Removed 'module "route-53"'


# --- Outputs ---

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.load-balancer.load_balancer_dns_name
}

output "rds_endpoint" {
  description = "The RDS database endpoint"
  value       = module.rds_db_instance.db_instance_endpoint
}