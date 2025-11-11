# VARIABLES
variable "bucket_name" {
  description = "S3 bucket name for storing Terraform remote state"
}
variable "name" {
  description = "Friendly name for tagging"
}
variable "environment" {
  description = "Environment tag for the bucket"
}

# S3 Bucket for Terraform remote state
resource "aws_s3_bucket" "remote_state_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.name
    Environment = var.environment
  }

  force_destroy = false  # prevent accidental deletion
}

# Output the bucket name
output "remote_state_s3_bucket_name" {
  value = aws_s3_bucket.remote_state_bucket.id
}
