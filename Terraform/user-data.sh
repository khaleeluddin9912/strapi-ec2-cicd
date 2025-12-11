#!/bin/bash
# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
apt-get install -y docker.io
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install AWS CLI
apt-get install -y awscli

# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 495456621686.dkr.ecr.ap-south-1.amazonaws.com

# Pull Docker image
docker pull 495456621686.dkr.ecr.ap-south-1.amazonaws.com/khaleel/strapi-app:${image_tag}

# Stop existing container if exists
docker stop strapi-app || true
docker rm strapi-app || true

# Run Strapi container
docker run -d --name strapi-app -p 1337:1337 495456621686.dkr.ecr.ap-south-1.amazonaws.com/khaleel/strapi-app:${image_tag}
