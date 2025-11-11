# Removed modules: alb, lb_target_group, aws_ceritification_manager, hosted_zone.

# -----------------------------------------------------------------------------
# 1. NETWORKING (VPC, Subnets)
# -----------------------------------------------------------------------------
module "networking" {
  source = "./networking" # Path to your networking module
  
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  environment          = "dev"
}

# -----------------------------------------------------------------------------
# 2. SECURITY GROUPS
# -----------------------------------------------------------------------------
module "security_group" {
  source = "./security-groups" # Path to your security group module

  vpc_id = module.networking.dev_proj_1_vpc_id
  environment = "dev"
  
  # IMPORTANT: We need to expose the application port (e.g., 5000) 
  # directly to the internet (0.0.0.0/0) since the ALB is removed.
  app_port = 5000 
  
  # Assuming the EC2 security group module now accepts an "app_port" variable
  # and opens it up to 0.0.0.0/0 for testing purposes.
}

# -----------------------------------------------------------------------------
# 3. EC2 INSTANCE (Application Server)
# -----------------------------------------------------------------------------
module "ec2" {
  source = "./ec2" # Path to your EC2 module

  vpc_id          = module.networking.dev_proj_1_vpc_id
  subnet_id       = module.networking.dev_proj_1_public_subnets[0]
  security_group_id = module.security_group.sg_ec2_sg_ssh_http_id # Using the updated SG
  environment     = "dev"
  
  # Add other required EC2 variables here (AMI, instance_type, key_name, etc.)
}

# -----------------------------------------------------------------------------
# 4. RDS DATABASE
# -----------------------------------------------------------------------------
module "rds_db_instance" {
  source = "./rds" # Path to your RDS module

  vpc_id          = module.networking.dev_proj_1_vpc_id
  private_subnets = module.networking.dev_proj_1_private_subnets
  db_sg_id        = module.security_group.sg_rds_db_sg_id
  environment     = "dev"
  
  # Add other required RDS variables here (engine, username, password, etc.)
}

# -----------------------------------------------------------------------------
# Outputs (Optional, but useful)
# -----------------------------------------------------------------------------
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = module.ec2.dev_proj_1_ec2_public_ip
}