# infra/variables.tf (Updated)
variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "name" {
  type        = string
  description = "Tag name"
  default     = "DevOps-Project-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR value"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "DevOps Project 1 VPC 1"
  default     = "DevOps-Project-1-VPC"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "eu_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "public_key" {
  type        = string
  description = "DevOps Project 1 Public key for EC2 instance"
  # You MUST replace the placeholder below with the actual name of your existing AWS Key Pair!
  default     = "YOUR_SSH_KEY_NAME_HERE" 
}

variable "ec2_ami_id" {
  type        = string
  description = "DevOps Project 1 AMI Id for EC2 instance"
  default     = "ami-09b9f29104c96996d" 
}

variable "tfstate_bucket_name" {
  type        = string
  description = "Remote state bucket name"
  default     = "devops-project-1-tfstate-bucket"
}