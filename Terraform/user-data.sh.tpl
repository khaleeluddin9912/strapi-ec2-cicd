#!/bin/bash
set -e  # Exit on error
set -x  # Debug mode

# ============================================
# 1. UPDATE SYSTEM
# ============================================
echo "Step 1: Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

# ============================================
# 2. INSTALL DOCKER (SIMPLE & RELIABLE)
# ============================================
echo "Step 2: Installing Docker..."
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Wait for Docker to fully start
echo "Waiting 15 seconds for Docker to start..."
sleep 15

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# ============================================
# 3. INSTALL AWS CLI v2 (CORRECT METHOD)
# ============================================
echo "Step 3: Installing AWS CLI..."
sudo apt-get install -y curl unzip

# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip -q awscliv2.zip
sudo ./aws/install --update

# Verify installation
aws --version

# ============================================
# 4. GET VARIABLES FROM TERRAFORM
# ============================================
ECR_REPO="${ecr_repo}"
IMAGE_TAG="${image_tag}"
AWS_REGION="${aws_region}"

echo "Configuration:"
echo "ECR_REPO: $ECR_REPO"
echo "IMAGE_TAG: $IMAGE_TAG"
echo "AWS_REGION: $AWS_REGION"

# ============================================
# 5. LOGIN TO AWS ECR
# ============================================
echo "Step 5: Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $ECR_REPO

# ============================================
# 6. PULL DOCKER IMAGE FROM ECR
# ============================================
echo "Step 6: Pulling Docker image..."
sudo docker pull $ECR_REPO:$IMAGE_TAG

# ============================================
# 7. STOP & REMOVE OLD CONTAINER
# ============================================
echo "Step 7: Cleaning old container..."
sudo docker stop strapi-app 2>/dev/null || true
sudo docker rm strapi-app 2>/dev/null || true

# ============================================
# 8. RUN STRAPI CONTAINER
# ============================================
echo "Step 8: Starting Strapi container..."
sudo docker run -d \
  --name strapi-app \
  -p 1337:1337 \
  --restart unless-stopped \
  $ECR_REPO:$IMAGE_TAG

# ============================================
# 9. VERIFY DEPLOYMENT
# ============================================
echo "Step 9: Verifying deployment..."
sleep 10

# Check if container is running
CONTAINER_STATUS=$(sudo docker ps --filter "name=strapi-app" --format "{{.Status}}")
if [ -n "$CONTAINER_STATUS" ]; then
    echo "✅ Container is running: $CONTAINER_STATUS"
else
    echo "❌ Container failed to start"
    sudo docker logs strapi-app 2>/dev/null || echo "No logs available"
fi

# ============================================
# 10. CREATE LOG FILE
# ============================================
echo "Step 10: Creating deployment log..."
cat > /home/ubuntu/deployment-status.txt << EOF
==========================================
STRAPI DEPLOYMENT STATUS
==========================================
Deployment Time: $(date)
ECR Repository: $ECR_REPO
Image Tag: $IMAGE_TAG
AWS Region: $AWS_REGION

Docker Status:
$(sudo docker ps --filter "name=strapi-app")

Container Logs (last 5 lines):
$(sudo docker logs --tail 5 strapi-app 2>/dev/null || echo "No logs available")

System Info:
Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "N/A")
Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "N/A")
==========================================
EOF

# ============================================
# 11. FINAL OUTPUT
# ============================================
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "UNKNOWN")

echo ""
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo "🌐 Strapi URL: http://$PUBLIC_IP:1337"
echo "🔧 Admin Panel: http://$PUBLIC_IP:1337/admin"
echo "📋 Status Log: /home/ubuntu/deployment-status.txt"
echo "=========================================="

# Test health endpoint (optional, runs in background)
(sleep 20 && curl -s http://localhost:1337/_health > /dev/null 2>&1 && echo "Health check passed" || echo "Health check failed") &
