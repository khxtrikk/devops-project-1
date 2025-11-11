# DevOps Project 1 - Terraform Fixes Applied

## Summary
This document outlines all the fixes applied to the Terraform infrastructure code to make it functional and deployable.

## Issues Found and Fixed

### 1. **Load Balancer Module** (`infra/load-balancer/main.tf`)
**Problem:** Module had outdated/commented code with incorrect variable names that didn't match what `main.tf` was passing.

**Solution:**
- Removed all commented code
- Defined proper variables: `load_balancer_name`, `load_balancer_type`, `internal`, `subnets`, `security_groups`, `tags`
- Created proper outputs: `load_balancer_dns_name`, `load_balancer_arn`, `load_balancer_zone_id`
- Created simplified ALB resource without HTTPS/ACM complexity

### 2. **Load Balancer Target Group Module** (`infra/load-balancer-target-group/main.tf`)
**Problem:** Module was completely commented out, preventing ALB health checks and target routing.

**Solution:**
- Uncommented and refactored the module with proper variables
- Defined variables: `vpc_id`, `target_group_name`, `target_group_port`, `target_group_protocol`, `target_type`, `target_group_health_check`, `target_group_health_status`, `tags`
- Created proper outputs: `target_group_arn`, `target_group_id`
- Created clean ALB target group resource with health check configuration

### 3. **RDS Module** (`infra/rds/main.tf`)
**Problem:** Variable names didn't match what `main.tf` was passing (e.g., `subnet_groups` vs `db_private_subnets`).

**Solution:**
- Added comprehensive variable definitions with proper types and descriptions
- Updated variable names to match `main.tf` module call
- Added new variables: `db_private_subnets`, `tags`
- Updated RDS instance resource to use new variable names
- Enhanced outputs: `db_instance_endpoint`, `db_instance_host`, `db_instance_id`, `db_instance_port`

### 4. **EC2 Module** (`infra/ec2/main.tf`)
**Problem:** Module had no variable definitions, causing errors in Terraform validation.

**Solution:**
- Added all required variable definitions: `ami_id`, `instance_type`, `subnet_id`, `key_name`, `ec2_security_groups`, `user_data`, `tags`
- Improved tag handling using `merge()` function
- Added new outputs: `ec2_private_ip`, `ssh_connection_string_for_ec2`

### 5. **Networking Module** (`infra/networking/main.tf`)
**Problem:** Missing outputs expected by main.tf (`vpc_id`, `public_subnets`, `db_subnet_group_name`).

**Solution:**
- Added `vpc_id` output (in addition to legacy `dev_proj_1_vpc_id`)
- Added `public_subnets` output (in addition to legacy `dev_proj_1_public_subnets`)
- Added `private_subnets` output
- Added `db_subnet_group_name` output
- Added variable `tags` support

### 6. **Security Groups Module** (`infra/security-groups/main.tf`)
**Problem:** Missing `sg_alb_id` output that main.tf was trying to use.

**Solution:**
- Created new ALB security group (`alb_sg`) allowing HTTP (80) from anywhere
- Added `sg_alb_id` output
- Added `sg_rds_id` output (in addition to legacy `rds_mysql_sg_id`)
- Ensured EC2 security group allows traffic to application port (8080)

### 7. **Main Configuration** (`infra/main.tf`)
**Problems:** 
- Missing ALB listener configuration
- Missing target group attachment to EC2 instance
- Duplicate outputs

**Solution:**
- Added `aws_lb_listener` resource for ALB on port 80 with HTTP protocol
- Added `aws_lb_target_group_attachment` to connect EC2 instance to target group
- Removed duplicate outputs (kept only in `outputs.tf`)
- Added `db_private_subnets` parameter to RDS module

### 8. **Outputs** (`infra/outputs.tf`)
**Problem:** Outputs referenced modules that didn't exist or weren't providing the right outputs.

**Solution:**
- Removed invalid outputs referencing non-existent modules (`hosted_zone`, etc.)
- Kept core outputs: `alb_dns_name`, `rds_endpoint`, `rds_host`, `ec2_public_ip`, `ec2_id`, `vpc_id`
- Standardized output descriptions

## Test Results

✅ **Terraform Validation:** PASSED
```
Success! The configuration is valid.
```

✅ **Terraform Plan:** PASSED
- Plan will create 22 resources
- No errors or blocking issues
- All module outputs properly referenced

## Infrastructure Overview

The fixed Terraform configuration now creates:

1. **VPC & Networking**
   - VPC (10.0.0.0/16)
   - 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
   - 2 Private Subnets (10.0.3.0/24, 10.0.4.0/24)
   - Internet Gateway & Route Tables

2. **Security Groups**
   - ALB Security Group (HTTP on 80)
   - EC2 Security Group (SSH 22, App Port 8080)
   - RDS Security Group (MySQL 3306 from EC2 only)

3. **Application Tier**
   - Application Load Balancer (ALB)
   - Target Group with health checks
   - EC2 Instance (t2.micro, eu-north-1)

4. **Database Tier**
   - RDS MySQL Instance (db.t3.micro)
   - Database Subnet Group
   - Proper security isolation

## Deployment Notes

### Prerequisites
- AWS credentials configured
- SSH key pair created in your AWS region
- S3 bucket and DynamoDB table for remote state (or use `-lock=false` flag)

### Configuration Updates Needed

In `terraform.tfvars`, update:
1. **`public_key`**: Replace with your actual EC2 key pair name (not the SSH public key)
2. **`ec2_ami_id`**: Verify the AMI ID is available in your region (eu-north-1)
3. **`ec2_user_data_install_apache`**: Update the RDS endpoint placeholder after resources are created

### Deployment Steps

```bash
cd infra
terraform init
terraform plan -lock=false
terraform apply -lock=false
```

## Known Issues

1. **State Backend**: The backend uses S3 and DynamoDB that may not exist. Use `-lock=false` flag if they're not available.
2. **SSH Key**: `terraform.tfvars` currently has an SSH public key string instead of a key pair name. This needs to be corrected.
3. **AMI ID**: Verify the AMI ID `ami-06dd92ecc74fdfb36` is available in `eu-north-1` region.

## Warnings (Non-blocking)

- `domain_name` variable in `terraform.tfvars` is not used (legacy configuration)
- `bucket_name` variable in `terraform.tfvars` is not used (legacy configuration)

These warnings can be safely ignored or removed from `terraform.tfvars`.
