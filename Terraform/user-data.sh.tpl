#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt-get install -y docker.io awscli
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ecr_repo}

# Pull and run container
docker pull ${ecr_repo}:${image_tag}
docker stop strapi-app || true
docker rm strapi-app || true
docker run -d --name strapi-app -p 1337:1337 ${ecr_repo}:${image_tag}
