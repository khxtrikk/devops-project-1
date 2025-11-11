# General Settings
bucket_name  = "dev-project-remote-statebucket-1"      # S3 bucket for state storage
name         = "environment"                          # Name of the environment
environment  = "dev-1"                               # The environment (dev-1 in this case)

# VPC and Subnet Configuration
vpc_cidr             = "10.0.0.0/16"                   # CIDR block for the VPC
vpc_name             = "dev-proj-eu-central-vpc-1"     # VPC name
cidr_public_subnet   = ["10.0.1.0/24", "10.0.2.0/24"]   # Public subnets CIDR blocks
cidr_private_subnet  = ["10.0.3.0/24", "10.0.4.0/24"]   # Private subnets CIDR blocks
eu_availability_zone = ["eu-central-1a", "eu-central-1b"]  # Availability Zones

# EC2 Key and Instance Configuration
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDwmgMHFJE7J4qepIzAZL3/yC6J0zsEAb/oHYL+WBBDNUjSH4TeHUnHVNe9b/pyPcub+O/HNvlGrzSxUp0xT0b3O7kkTtgBKiG8NaBbonj+c7byfOGER80DYxc5adlBltuIDd8StFe7OMzbYyUSr1mdxDTIWm/OoE39G/fu3hTqUGkykv072GAy8nMFejITRw9pf+53B9ziE5rsdOUH4uqBiQa/Ng/qKo7h9MtJGcloRATYiObXwAgrHtt3sDrtvkq2ZceT906/BJm1Twlm+BHlQecHV18Ak3bzm/6HzlsA/q+yORsoB+VxSUxvVy0nXTc1X8vJAD4KSYVL5DTrpisdnQAIcuqAbea+LMku2o4sdnrrIlUi8/8BXeVbI4TNNGd0+sWpCVcDEhb4gyA/XXTvloQyjTYrL4+am/9XEY6NGdsrPK74sjvtpUZPUrmzTJ/mJWG5ncGY88GAj+YZAsY5pnAqh2CkR2TUpglugldnWyrppbe2QyC9iQkgUGSkBTs= rahulwagh@Rahuls-MacBook-Pro.local" # Replace this with your actual SSH public key
ec2_ami_id     = "ami-06dd92ecc74fdfb36"               # The AMI ID for your EC2 instance

# EC2 User Data Script
ec2_user_data_install_apache = ""  # Provide user-data script for Apache installation, if necessary

# Domain Name (for Hosted Zone and ACM)
domain_name = "jhooq.org"  # The domain name for your hosted zone and ACM certificate
