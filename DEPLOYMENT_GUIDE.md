# DevOps Project 1 - Local & Jenkins Setup Guide

## ✅ Current Status

- ✅ **Terraform Configuration**: VALIDATED & WORKING
- ✅ **Backend Setup**: S3 (eu-west-1) + DynamoDB locking enabled
- ✅ **Region**: eu-west-1 (Ireland)
- ⚠️ **AWS Setup**: Missing EC2 key pair name configuration
- ⏳ **Jenkins Pipeline**: Ready to setup

---

## 📋 Quick Start Checklist

### 1. **Configure Your EC2 Key Pair** ⚠️ CRITICAL
You must update your EC2 key pair name in `terraform.tfvars`:

```bash
# Find your EC2 key pair in AWS
# Go to: AWS Console → EC2 → Key Pairs → Note the key pair name

# Then update terraform.tfvars:
public_key = "your-actual-key-pair-name"  # Replace this!
```

### 2. **Deploy Infrastructure Locally** (Test before Jenkins)

```bash
cd infra

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview what will be created
terraform plan

# Create the infrastructure (after confirming plan output)
terraform apply

# Get the outputs
terraform output
```

### 3. **Update RDS Endpoint** (After infrastructure is created)

After `terraform apply` completes:

1. Get the RDS endpoint:
   ```bash
   terraform output rds_endpoint
   ```

2. Update the endpoint in `terraform.tfvars`:
   ```
   ec2_user_data_install_apache = "#!/bin/bash\n...
   -e DB_HOST=<YOUR_RDS_ENDPOINT_HERE> \
   ```

3. Re-apply (the EC2 instance will restart with correct DB connection):
   ```bash
   terraform apply
   ```

### 4. **Setup Jenkins Pipeline**

#### Prerequisites:
- Jenkins running with AWS plugin
- Jenkins AWS credentials configured with ID: `aws-credentials-Khatri`

#### Configure Jenkins:

1. **Add Jenkins Credentials:**
   - Go to Jenkins → Manage Jenkins → Credentials → Add Credentials
   - Kind: AWS Credentials
   - ID: `aws-credentials-Khatri`
   - Access Key: Your AWS access key
   - Secret Key: Your AWS secret key

2. **Create Jenkins Job:**
   - New Item → Pipeline
   - Pipeline → Pipeline script from SCM
   - SCM: Git
   - Repository URL: https://github.com/khxtrikk/devops-project-1.git
   - Branch: main

3. **Run Pipeline:**
   - Build with parameters:
     - `PLAN_TERRAFORM`: check this first
     - `APPLY_TERRAFORM`: check this to actually create resources

---

## 🏗️ Infrastructure Overview

Your setup will create in **eu-west-1 (Ireland)**:

### Network Layer
- VPC: 10.0.0.0/16
- 2 Public Subnets: 10.0.1.0/24, 10.0.2.0/24
- 2 Private Subnets: 10.0.3.0/24, 10.0.4.0/24
- Internet Gateway & Route Tables

### Security
- ALB Security Group (HTTP 80 from anywhere)
- EC2 Security Group (SSH 22 + App Port 8080)
- RDS Security Group (MySQL 3306 from EC2 only)

### Application
- Application Load Balancer (ALB)
- EC2 Instance (t2.micro) - runs Docker container
- RDS MySQL (db.t3.micro)

### Backend (State Management)
- S3: `dev-project-remote-statebucket-12` (eu-west-1)
- DynamoDB: `terraform-locks` (eu-west-1) - for state locking
- State file: `devops/project1/terraform.tfstate`

---

## 📊 Current Configuration

**File: `infra/terraform.tfvars`**
```terraform
# Region
aws_region = "eu-west-1"  # Ireland

# Network
vpc_cidr = "10.0.0.0/16"
eu_availability_zone = ["eu-west-1a", "eu-west-1b"]

# Application
name = "environment"
environment = "dev-1"

# Database
db_name = "project1db"
db_user = "project1user"
db_password = "project1dbpassword"  # ⚠️ CHANGE THIS in production!

# EC2
public_key = "YOUR_EC2_KEY_PAIR_NAME"  # ⚠️ MUST UPDATE THIS!
ec2_ami_id = "ami-0d2a4a5d69e46ea0b"  # Amazon Linux 2 for eu-west-1

# Docker Application
app_image = "khxtrikk/rest-api:latest"
app_port = 8080
```

---

## 🔑 Required AWS Resources (Already Created)

✅ S3 Bucket: `dev-project-remote-statebucket-12` (eu-west-1)
✅ DynamoDB Table: `terraform-locks` (eu-west-1)
⚠️ EC2 Key Pair: You need to provide the name

---

## 🚀 Deployment Flow

### Local (for testing):
```
1. terraform init
2. terraform plan
3. terraform apply
4. Get outputs (ALB DNS, RDS endpoint, EC2 IP)
5. Test application
```

### Jenkins (for CI/CD):
```
1. Trigger pipeline with PLAN_TERRAFORM=true
2. Review the plan output
3. Trigger pipeline with APPLY_TERRAFORM=true
4. Pipeline creates infrastructure via Terraform
5. Pipeline outputs resource details
```

---

## 📤 Outputs After Deployment

```
alb_dns_name    = "environment-<random>.eu-west-1.elb.amazonaws.com"
ec2_public_ip   = "192.0.2.xxx"
rds_endpoint    = "project1db-instance.xxx.eu-west-1.rds.amazonaws.com:3306"
vpc_id          = "vpc-xxxxx"
```

---

## ⚠️ Important Notes

1. **Database Password**: Currently set to `project1dbpassword` - change in production!
2. **EC2 Key Pair**: Must exist in eu-west-1 - create before deployment
3. **Docker Image**: Uses `khxtrikk/rest-api:latest` - ensure it supports port 8080
4. **Cost**: t2.micro instances are eligible for free tier in first year
5. **State Locking**: Prevents concurrent Terraform runs - important for CI/CD

---

## 🔍 Troubleshooting

### Terraform Plan Fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify backend connectivity
terraform init -reconfigure

# Check region
aws ec2 describe-regions --region-names eu-west-1
```

### Jenkins Pipeline Fails
1. Check Jenkins logs: Jenkins → Manage Jenkins → System Log
2. Verify credential ID: Manage Jenkins → Credentials
3. Verify Jenkins can access GitHub: Test connection
4. Check AWS credentials permissions (EC2, RDS, ALB, VPC access)

### EC2 Instance Won't Start
1. Verify key pair name is correct
2. Check security group allows inbound SSH
3. Verify AMI exists in eu-west-1

### Application Not Accessible
1. Check ALB listener on port 80
2. Check target group health (should show "Healthy")
3. Check EC2 instance security group allows port 8080
4. Verify Docker container is running:
   ```bash
   ssh -i your-key.pem ec2-user@<EC2_IP>
   docker ps
   ```

---

## 🛠️ Manual Fixes

### If You Need to Change Region:
Update these files:
- `infra/main.tf` - backend region
- `infra/variables.tf` - default aws_region
- `infra/terraform.tfvars` - eu_availability_zone
- `Jenkinsfile` - region in provider configuration

### If You Need Different EC2 Instance Type:
Update `infra/terraform.tfvars`:
```terraform
# Change from t2.micro to:
instance_type = "t3.small"  # More CPU/Memory
```

---

## 📞 Next Steps

1. ✅ **Update EC2 key pair name** in terraform.tfvars
2. ✅ **Run terraform plan** locally to verify
3. ✅ **Run terraform apply** locally to create resources
4. ✅ **Configure Jenkins** credentials
5. ✅ **Run Jenkins pipeline** to verify CI/CD works
6. ✅ **Test application** via ALB DNS name

**Ready to deploy? Let me know!** 🚀
