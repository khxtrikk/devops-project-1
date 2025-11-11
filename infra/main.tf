# Root Terraform file (infra/main.tf)
# Changes: 
# 1. Corrected 'module "ec2"' argument to 'ec2_security_groups'. (Line 58)
# 2. Removed or commented out all modules related to DNS (Route 53), ACM, and ALB listeners that require a domain.

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
  public_subnet_cidr_block = var.vpc_cidr # Assuming the VPC CIDR is used for SSH access source
  ec2_sg_name              = "webapp-ec2-sg"
  app_port                 = 8080 # Assuming your application listens on port 8080
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
  ec2_security_groups            = [module.security_group.sg_ec2_sg_ssh_http_id] # FIX: Corrected argument name
  user_data                      = var.ec2_user_data_install_apache
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

# --- Output the EC2 Public IP for access (since DNS is removed) ---

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2.ec2_public_ip
}

# --- Load Balancer Module (Commented out to keep the file clean, but ALB likely won't work without a listener configured)
# The EC2 module configuration above deploys the instance directly in a public subnet, 
# making the ALB unnecessary if you access via Public IP. 

/*
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
*/

# --- Domain/SSL-Related Modules (REMOVED) ---

# Removed 'module "hosted-zone"'
# Removed 'module "certificate-manager"'
# Removed 'module "load-balancer-target-group"' 
# Removed 'module "load-balancer-listener"'
# Removed 'module "route-53"'