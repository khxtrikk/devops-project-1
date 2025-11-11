# Removed modules: alb, lb_target_group, aws_ceritification_manager, hosted_zone.

# -----------------------------------------------------------------------------
# 1. NETWORKING (VPC, Subnets)
# -----------------------------------------------------------------------------
module "networking" {
  source = "./networking" # Path to your networking module

  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "rest-api-vpc"                 # NEW: Required missing argument
  cidr_public_subnet   = "10.0.1.0/24"                  # NEW: Required missing argument (using only the first CIDR)
  cidr_private_subnet  = "10.0.11.0/24"                 # NEW: Required missing argument (using only the first CIDR)
  eu_availability_zone = "eu-west-1a"
}

# -----------------------------------------------------------------------------
# 2. SECURITY GROUPS
# -----------------------------------------------------------------------------
module "security_group" {
  source = "./security-groups" # Path to your security group module

  vpc_id      = module.networking.dev_proj_1_vpc_id
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

  # --- Required Arguments (Added/Fixed based on console output errors) ---
  # NOTE: Replace all "YOUR_..." placeholders with actual values.

  ami_id                     = "ami-0abcdef1234567890"        # Missing: Replace with your chosen AMI ID (e.g., Ubuntu/Amazon Linux)
  instance_type              = "t2.micro"                     # Missing: Replace with your desired instance type
  tag_name                   = "rest-api-server-dev"          # Missing: Name tag for the EC2 instance
  public_key                 = file("YOUR_SSH_KEY_NAME.pub")  # Missing: Path to your SSH public key file
  user_data_install_apache   = ""                             # Missing: Can be an empty string or a path to a script (e.g., file("./install.sh"))
  enable_public_ip_address   = true                           # Missing: Set to 'true' to ensure a public IP is assigned
  sg_enable_ssh_https        = true                           # Missing: Boolean to control ports 22/443 on the SG
  ec2_sg_name_for_python_api = "ec2-app-sg"                   # Missing: Name for the EC2 Security Group

  # --- Existing & Supported Arguments ---
  subnet_id                  = module.networking.dev_proj_1_public_subnets[0]

  # --- Arguments Removed (Unsupported based on console output errors) ---
  # vpc_id (removed)
  # security_group_id (removed - likely handled internally by the module now)
  # environment (removed)
}

# -----------------------------------------------------------------------------
# 4. RDS DATABASE
# -----------------------------------------------------------------------------
module "rds_db_instance" {
  source = "./rds" # Path to your RDS module

  mysql_db_identifier    = "rest-api-db-instance"        # NEW: Required missing argument
  mysql_username         = "appuser"                     # NEW: Required missing argument
  mysql_password         = "YOUR_SECURE_PASSWORD"        # NEW: Required missing argument (USE SECRETS OR VAULT FOR REAL DEPLOYMENTS)
  mysql_dbname           = "rest_api_db"                 # NEW: Required missing argument
  db_subnet_group_name   = "rest-api-db-sg"              # NEW: Required missing argument
  subnet_groups          = module.networking.dev_proj_1_private_subnets # NEW: Required missing argument (Assuming this takes the subnet list)
  rds_mysql_sg_id        = module.security_group.sg_rds_db_sg_id # NEW: Required missing argument (Renamed to match module expectation)

  # Add other required RDS variables here (engine, username, password, etc.)
}

# -----------------------------------------------------------------------------
# Outputs (Optional, but useful)
# -----------------------------------------------------------------------------
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = module.ec2.dev_proj_1_ec2_public_ip
}