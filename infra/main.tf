# main.tf

# -----------------------------------------------------------------------------
# 1. NETWORKING (VPC, Subnets)
# -----------------------------------------------------------------------------
module "networking" {
  source = "./networking" # Path to your networking module

  # Arguments required by the networking module based on variables.tf:
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet   # Note: This is a list(string)
  cidr_private_subnet  = var.cidr_private_subnet  # Note: This is a list(string)
  eu_availability_zone = var.eu_availability_zone # Note: This is a list(string)
  
  # Assuming your networking module uses the 'environment' and 'name' variables for tags:
  environment = var.environment
  name        = var.name
}

# -----------------------------------------------------------------------------
# 2. SECURITY GROUPS
# -----------------------------------------------------------------------------
module "security_group" {
  source = "./security-groups" # Path to your security group module

  # Assuming your security group module expects these variables:
  vpc_id      = module.networking.dev_proj_1_vpc_id
  environment = var.environment
  
  # IMPORTANT: We need to expose the application port (e.g., 5000) 
  # directly to the internet (0.0.0.0/0) since the ALB is removed.
  app_port = 5000 
}

# -----------------------------------------------------------------------------
# 3. EC2 INSTANCE (Application Server)
# -----------------------------------------------------------------------------
module "ec2" {
  source = "./ec2" # Path to your EC2 module

  # Required EC2 variables based on your previous errors (using variables.tf now):
  ami_id                     = var.ec2_ami_id
  instance_type              = "t2.micro"                  # PLACEHOLDER: Define this as a variable or hardcode
  tag_name                   = var.name
  public_key                 = var.public_key
  user_data_install_apache   = var.ec2_user_data_install_apache
  
  # Assuming these boolean flags are still required by your EC2 module:
  enable_public_ip_address   = true
  sg_enable_ssh_https        = true 
  ec2_sg_name_for_python_api = "${var.name}-ec2-sg"          # Assuming a dynamic name based on 'name'
  
  # Assuming these resources are still required by your EC2 module:
  subnet_id                  = module.networking.dev_proj_1_public_subnets[0]
  security_group_id          = [module.security_group.sg_ec2_sg_ssh_http_id]
}

# -----------------------------------------------------------------------------
# 4. RDS DATABASE
# -----------------------------------------------------------------------------
module "rds_db_instance" {
  source = "./rds" # Path to your RDS module

  # Required RDS variables based on your previous errors:
  mysql_db_identifier    = "${var.name}-rds"                 # Using 'name' for identifier
  mysql_username         = "appuser"                         # PLACEHOLDER: Define this as a variable or hardcode
  mysql_password         = "zack"            # PLACEHOLDER: Use a secure method (see previous advice)
  mysql_dbname           = "${var.name}_db"                  # Using 'name' for DB name
  db_subnet_group_name   = "${var.name}-db-sg"               # Using 'name' for subnet group name
  
  # Linking to other resources:
  subnet_groups          = module.networking.dev_proj_1_private_subnets 
  rds_mysql_sg_id        = module.security_group.sg_rds_db_sg_id
}

# -----------------------------------------------------------------------------
# Outputs (Optional, but useful)
# -----------------------------------------------------------------------------
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = module.ec2.dev_proj_1_ec2_public_ip
}