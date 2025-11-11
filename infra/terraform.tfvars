# General Settings
bucket_name  = "dev-project-remote-statebucket-12"      # S3 bucket for state storage (in eu-west-1)
name         = "environment"                          # Name of the environment
environment  = "dev-1"                               # The environment (dev-1 in this case)

# VPC and Subnet Configuration
vpc_cidr             = "10.0.0.0/16"                   # CIDR block for the VPC
vpc_name             = "dev-proj-eu-west-vpc-1"        # VPC name
cidr_public_subnet   = ["10.0.1.0/24", "10.0.2.0/24"]   # Public subnets CIDR blocks
cidr_private_subnet  = ["10.0.3.0/24", "10.0.4.0/24"]   # Private subnets CIDR blocks
eu_availability_zone = ["eu-west-1a", "eu-west-1b"]  # Availability Zones

# EC2 Key and Instance Configuration
public_key = "aws_ec2_terraform"               # Replace with your actual EC2 key pair name (e.g., "my-devops-key")
ec2_ami_id     = "ami-0d2a4a5d69e46ea0b"               # Amazon Linux 2 AMI for eu-west-1 (Ireland)

# Domain Name (for Hosted Zone and ACM)
domain_name = "jhooq.org"  # The domain name for your hosted zone and ACM certificate

