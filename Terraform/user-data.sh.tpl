#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y docker.io awscli
sudo systemctl enable docker
sudo systemctl start docker
sleep 10
sudo usermod -aG docker ubuntu

# Login to ECR
aws ecr get-login-password --region ap-south-1 | sudo docker login --username AWS --password-stdin ${ecr_repo}

# Pull and run container
sudo docker pull ${ecr_repo}:${image_tag}
sudo docker stop strapi-app || true
sudo docker rm strapi-app || true
sudo docker run -d --name strapi-app -p 1337:1337 ${ecr_repo}:${image_tag}
