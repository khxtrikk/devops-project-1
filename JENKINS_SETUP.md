# Jenkins Pipeline Setup Guide

## ✅ Prerequisites

1. **Jenkins Server Running** with:
   - Git plugin installed
   - Pipeline plugin installed
   - AWS credentials plugin installed (`cloudbees-credentials` or `aws-credentials`)

2. **Terraform Installed** on Jenkins agent
   ```bash
   # Check if terraform is installed
   terraform -version
   
   # If not, install:
   # Linux/Mac: brew install terraform
   # Windows: choco install terraform
   ```

3. **AWS Credentials** configured locally on Jenkins agent
   ```bash
   aws configure
   # Enter: Access Key ID, Secret Access Key, Region, Output Format
   ```

---

## 🔑 Step 1: Create Jenkins AWS Credentials

**Go to Jenkins Dashboard:**

1. Click **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** domain
3. Click **Add Credentials**
4. Fill in the form:
   - **Kind:** AWS Credentials
   - **ID:** `aws-credentials-Khatri` ← **IMPORTANT: Must match Jenkinsfile**
   - **Description:** DevOps Project 1 AWS Credentials
   - **Access Key ID:** Your AWS access key
   - **Secret Access Key:** Your AWS secret key
5. Click **Create**

**Verify the credential ID is exactly:** `aws-credentials-Khatri`

---

## 📦 Step 2: Create Jenkins Pipeline Job

### Option A: Via UI (Easier)

1. Jenkins Home → **New Item**
2. Enter name: `devops-project-1-pipeline`
3. Select **Pipeline**
4. Click **OK**
5. In the **Pipeline** section, select:
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** `https://github.com/khxtrikk/devops-project-1.git`
   - **Credentials:** (leave empty for public repo, or add GitHub token)
   - **Branch:** `*/main`
   - **Script Path:** `Jenkinsfile`
6. Click **Save**

### Option B: Via Configuration as Code (Advanced)

Create a `jenkins.yaml` file and use Jenkins Configuration as Code plugin.

---

## 🚀 Step 3: Run the Pipeline

### First Run - Plan Only (SAFE)

1. Go to your pipeline job: `devops-project-1-pipeline`
2. Click **Build with Parameters**
3. Set:
   - ✅ `PLAN_TERRAFORM` = checked
   - ❌ `APPLY_TERRAFORM` = unchecked
   - ❌ `DESTROY_TERRAFORM` = unchecked
4. Click **Build**
5. Watch the build logs - you should see:
   ```
   =================Terraform Init====================
   =================Terraform Plan====================
   Plan: 22 to add, 0 to change, 0 to destroy.
   ```

### Second Run - Apply (CREATES RESOURCES)

**⚠️ IMPORTANT: Only run after verifying plan is correct!**

1. Click **Build with Parameters** again
2. Set:
   - ❌ `PLAN_TERRAFORM` = unchecked
   - ✅ `APPLY_TERRAFORM` = checked
   - ❌ `DESTROY_TERRAFORM` = unchecked
3. Click **Build**
4. Watch the logs - at the end you should see:
   ```
   =================Terraform Outputs====================
   alb_dns_name = "environment-xxx.eu-west-1.elb.amazonaws.com"
   ec2_public_ip = "192.0.2.xxx"
   rds_endpoint = "project1db-instance.xxx.eu-west-1.rds.amazonaws.com:3306"
   vpc_id = "vpc-xxxxx"
   
   Deployment completed successfully!
   Access your application at: http://environment-xxx.eu-west-1.elb.amazonaws.com
   ```

### Optional - Destroy Resources

**⚠️ CAUTION: This deletes everything!**

1. Click **Build with Parameters**
2. Set:
   - ❌ `PLAN_TERRAFORM` = unchecked
   - ❌ `APPLY_TERRAFORM` = unchecked
   - ✅ `DESTROY_TERRAFORM` = checked
3. Click **Build**
4. Resources will be deleted

---

## 🔍 Pipeline Stages Explained

### Stage 1: Clone Repository
- Downloads your code from GitHub

### Stage 2: Terraform Init
- Initializes Terraform
- Connects to S3 backend and DynamoDB locking
- Downloads AWS provider

### Stage 3: Terraform Plan
- **If PLAN_TERRAFORM=true:** Shows what will be created
- **Saves plan to file** (`tfplan`) for apply stage
- **Does NOT create resources**

### Stage 4: Terraform Apply
- **If APPLY_TERRAFORM=true:** Creates AWS resources
- Uses saved plan from stage 3
- **Creates real infrastructure** (VPC, EC2, RDS, ALB, etc.)

### Stage 5: Terraform Destroy
- **If DESTROY_TERRAFORM=true:** Deletes all resources
- **⚠️ Use carefully**

### Stage 6: Output Deployment Details
- **If APPLY_TERRAFORM=true:** Shows outputs
- Displays ALB DNS name for accessing application

---

## 🐛 Troubleshooting

### Error: "Could not find credentials"

**Solution:**
```bash
# On Jenkins agent, verify AWS credentials:
aws sts get-caller-identity

# If it fails:
aws configure
# Enter your AWS Access Key ID and Secret Access Key
```

### Error: "Credential ID 'aws-credentials-Khatri' not found"

**Solution:**
1. Check Jenkins credential ID exactly matches: `aws-credentials-Khatri`
2. Go to: Manage Jenkins → Credentials → Verify the ID
3. If different, update **Jenkinsfile** line 5:
   ```groovy
   AWS_CRED_ID = 'your-actual-credential-id'
   ```

### Error: "terraform: command not found"

**Solution:**
```bash
# Install Terraform on Jenkins agent
# Linux:
curl https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install terraform

# Mac:
brew install terraform

# Windows:
choco install terraform
```

### Error: "Unable to retrieve item from DynamoDB"

**Solution:**
- DynamoDB `terraform-locks` table exists but is in wrong region
- This is already fixed in your config (eu-west-1)
- If error persists, verify:
  ```bash
  aws dynamodb describe-table --table-name terraform-locks --region eu-west-1
  ```

### Error: "Could not download provider"

**Solution:**
- Jenkins agent needs internet access to download Terraform providers
- Ensure Jenkins can access: `registry.terraform.io`

### Build Skipped (No Output)

**Solution:**
- You didn't check any parameter boxes
- Example: If you run with all unchecked, nothing happens (this is intentional)
- Always check at least one: `PLAN_TERRAFORM` or `APPLY_TERRAFORM`

---

## 📊 Pipeline Output Example

```
Started by user admin
Running in Workspace /var/lib/jenkins/workspace/devops-project-1-pipeline
[Pipeline] node
Running on Jenkins in /var/lib/jenkins/workspace/devops-project-1-pipeline
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Clone Repository)
[Pipeline] deleteDir
[Pipeline] git
Cloning into '/var/lib/jenkins/workspace/devops-project-1-pipeline'...
From https://github.com/khxtrikk/devops-project-1
 * branch            main     -> FETCH_HEAD
 * [new branch]      main     -> origin/main
[Pipeline] sh
+ ls -lart
total 48
drwxr-xr-x  5 jenkins jenkins  4096 Nov 11 13:45 .
drwxr-xr-x 13 jenkins jenkins  4096 Nov 11 13:45 ..
-rw-r--r--  1 jenkins jenkins  1234 Nov 11 13:45 README.md
-rw-r--r--  1 jenkins jenkins  2345 Nov 11 13:45 Jenkinsfile
drwxr-xr-x  3 jenkins jenkins  4096 Nov 11 13:45 infra
[Pipeline] }
[Pipeline] stage
[Pipeline] { (Terraform Init)
=================Terraform Init====================
Initializing the backend...
Successfully configured the backend "s3"!
Initializing modules...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.26.0
Terraform has been successfully initialized!
[Pipeline] stage
[Pipeline] { (Terraform Plan)
=================Terraform Plan====================
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
Plan: 22 to add, 0 to change, 0 to destroy.
[Pipeline] stage
[Pipeline] { (Output Deployment Details)
=================Terraform Outputs====================
alb_dns_name = "environment-abc123.eu-west-1.elb.amazonaws.com"
ec2_public_ip = "54.123.45.67"
rds_endpoint = "project1db-instance.clvxxx.eu-west-1.rds.amazonaws.com:3306"
vpc_id = "vpc-12345abc"
Deployment completed successfully!
Access your application at: http://environment-abc123.eu-west-1.elb.amazonaws.com
[Pipeline] }
```

---

## ✅ Verification Checklist

After running the pipeline successfully:

- [ ] VPC created with correct CIDR (10.0.0.0/16)
- [ ] 2 public + 2 private subnets created
- [ ] ALB running and accessible via DNS name
- [ ] EC2 instance running with Docker container
- [ ] RDS database created and accessible from EC2
- [ ] All security groups configured correctly
- [ ] Terraform state stored in S3 with DynamoDB locking

---

## 🔄 Continuous Integration

To make the pipeline run automatically on GitHub push:

1. Go to your GitHub repo → Settings → Webhooks → Add webhook
2. Set:
   - **Payload URL:** `https://your-jenkins.com/github-webhook/`
   - **Content type:** application/json
   - **Events:** Push events
3. In Jenkins job → Configure → Build Triggers → Check "GitHub hook trigger for GITScm polling"
4. Now every push to main branch will trigger the pipeline

---

## 📞 Support

**Common Issues:**
- Credential ID mismatch → Check Jenkinsfile line 5
- Terraform not found → Install Terraform on Jenkins agent
- AWS permissions → Ensure IAM user has EC2, RDS, ALB, VPC permissions
- State lock issue → DynamoDB table exists in eu-west-1 (already configured)

**Need Help?**
Check Jenkins logs: Jenkins → Manage Jenkins → System Log
