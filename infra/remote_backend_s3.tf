terraform {
  backend "s3" {
    bucket         = "your-unique-prefix-terraform-remote-state-12345" # Your unique S3 bucket name
    key            = "dev-proj-1/terraform.tfstate"   # The path where the state file will be stored
    region         = "eu-central-1"                   # Your AWS region
    dynamodb_table = "terraform-locks"                # For state locking (optional)
    encrypt        = true                             # Enable state file encryption
  }
}
