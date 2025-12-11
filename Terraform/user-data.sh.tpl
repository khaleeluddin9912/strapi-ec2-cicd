#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y docker.io awscli
sudo systemctl enable docker
sudo systemctl start docker
sleep 10
sudo usermod -aG docker ubuntu

# Variables passed from Terraform
ECR_REPO="${ecr_repo}"
IMAGE_TAG="${image_tag}"

# Login to ECR
aws ecr get-login-password --region ap-south-1 | sudo docker login --username AWS --password-stdin $ECR_REPO

# Pull and run container
sudo docker pull $ECR_REPO:$IMAGE_TAG
sudo docker stop strapi-app || true
sudo docker rm strapi-app || true

sudo docker run -d --name strapi-app -p 1337:1337 $ECR_REPO:$IMAGE_TAG
