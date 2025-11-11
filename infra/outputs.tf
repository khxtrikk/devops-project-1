output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.load-balancer.load_balancer_dns_name
}

output "rds_endpoint" {
  description = "The RDS database endpoint"
  value       = module.rds_db_instance.db_instance_endpoint
}

output "rds_host" {
  description = "The hostname of the RDS instance"
  value       = module.rds_db_instance.db_instance_host
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = module.ec2.ec2_public_ip
}

output "ec2_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.ec2_id
}

output "vpc_id" {
  description = "The VPC ID"
  value       = module.networking.vpc_id
}
