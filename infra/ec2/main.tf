# infra/ec2/main.tf (Updated)
# Ensure the variable name passed to this module is correctly used here.
resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.ec2_security_groups # FIX: Using the correct input variable name
  user_data                   = var.user_data
  associate_public_ip_address = true

  tags = {
    Name        = var.tags["Name"]
    Environment = var.tags["Environment"]
  }
}

# --- Outputs ---

output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "ec2_id" {
  value = aws_instance.app_server.id
}