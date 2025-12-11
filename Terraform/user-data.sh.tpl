#!/bin/bash

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker and AWS CLI
sudo apt-get install -y docker.io awscli

# Start and enable Docker
sudo systemctl enable docker
sudo systemctl start docker

# ✅ WAIT for Docker to fully start
sleep 30

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Variables from Terraform - ADDED AWS_REGION
ECR_REPO="${ecr_repo}"
IMAGE_TAG="${image_tag}"
AWS_REGION="${aws_region}"  # ✅ Added this line

# ✅ FIX: Use the AWS_REGION variable, not hardcoded
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REPO

# Pull Docker image
sudo docker pull $ECR_REPO:$IMAGE_TAG

# Stop and remove existing container
sudo docker stop strapi-app 2>/dev/null || true
sudo docker rm strapi-app 2>/dev/null || true

# ✅ WAIT before running container
sleep 10

# Run Strapi container
sudo docker run -d \
  --name strapi-app \
  -p 1337:1337 \
  --restart unless-stopped \  # ✅ Added restart policy
  $ECR_REPO:$IMAGE_TAG

# ✅ Check if container is running
echo "Checking container status..."
sleep 15  # Wait for container to fully start
sudo docker ps

echo "========================================"
echo "Strapi deployed successfully!"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "Strapi URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):1337"
echo "========================================"