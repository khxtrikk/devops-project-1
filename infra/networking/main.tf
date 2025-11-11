variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "eu_availability_zone" {}
variable "cidr_private_subnet" {}
variable "tags" {
  type    = map(string)
  default = {}
}

output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.dev_proj_1_vpc_eu_central_1.id
}

output "dev_proj_1_vpc_id" {
  description = "The VPC ID (legacy output name)"
  value       = aws_vpc.dev_proj_1_vpc_eu_central_1.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.dev_proj_1_public_subnets[*].id
}

output "dev_proj_1_public_subnets" {
  description = "List of public subnet IDs (legacy output name)"
  value       = aws_subnet.dev_proj_1_public_subnets[*].id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.dev_proj_1_private_subnets[*].id
}

output "dev_proj_1_private_subnets" {
  description = "List of private subnet IDs (legacy output name)"
  value       = aws_subnet.dev_proj_1_private_subnets[*].id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group (will be created by RDS module)"
  value       = "dev-proj-1-db-subnet-group"
}

output "public_subnet_cidr_block" {
  description = "CIDR blocks of public subnets"
  value       = aws_subnet.dev_proj_1_public_subnets[*].cidr_block
}

# Setup VPC
resource "aws_vpc" "dev_proj_1_vpc_eu_central_1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}


# Setup public subnet
resource "aws_subnet" "dev_proj_1_public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.dev_proj_1_vpc_eu_central_1.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "dev-proj-public-subnet-${count.index + 1}"
  }
}

# Setup private subnet
resource "aws_subnet" "dev_proj_1_private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.dev_proj_1_vpc_eu_central_1.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "dev-proj-private-subnet-${count.index + 1}"
  }
}

# Setup Internet Gateway
resource "aws_internet_gateway" "dev_proj_1_public_internet_gateway" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_central_1.id
  tags = {
    Name = "dev-proj-1-igw"
  }
}

# Public Route Table
resource "aws_route_table" "dev_proj_1_public_route_table" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_central_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_proj_1_public_internet_gateway.id
  }
  tags = {
    Name = "dev-proj-1-public-rt"
  }
}

# Public Route Table and Public Subnet Association
resource "aws_route_table_association" "dev_proj_1_public_rt_subnet_association" {
  count          = length(aws_subnet.dev_proj_1_public_subnets)
  subnet_id      = aws_subnet.dev_proj_1_public_subnets[count.index].id
  route_table_id = aws_route_table.dev_proj_1_public_route_table.id
}

# Private Route Table
resource "aws_route_table" "dev_proj_1_private_rt" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_central_1.id
  tags = {
    Name = "dev-proj-1-private-rt"
  }
}

# Private Route Table and private Subnet Association
resource "aws_route_table_association" "dev_proj_1_private_rt_subnet_association" {
  count          = length(aws_subnet.dev_proj_1_private_subnets)
  subnet_id      = aws_subnet.dev_proj_1_private_subnets[count.index].id
  route_table_id = aws_route_table.dev_proj_1_private_rt.id
}