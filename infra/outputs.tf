output "dev_proj_1_vpc_id" {
  value = module.networking.dev_proj_1_vpc_id
}

output "sg_ec2_sg_ssh_http_id" {
  value = module.security_group.sg_ec2_sg_ssh_http_id
}

output "rds_mysql_sg_id" {
  value = module.security_group.rds_mysql_sg_id
}

output "sg_ec2_for_python_api" {
  value = module.security_group.sg_ec2_for_python_api
}

output "ec2_ssh_string" {
  value = module.ec2.ssh_connection_string_for_ec2
}

output "hosted_zone_id" {
  value = module.hosted_zone.hosted_zone_id
}
