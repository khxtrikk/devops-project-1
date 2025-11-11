#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
docker pull khxtrikk/rest-api:latest

# Run the application container with the RDS endpoint injected
docker rm -f rest-api || true
docker run -d -p 8080:8080 \
  -e DB_HOST=${rds_endpoint} \
  -e DB_USER=project1user \
  -e DB_PASSWORD=project1dbpassword \
  -e DB_NAME=project1db \
  --name rest-api khxtrikk/rest-api:latest
