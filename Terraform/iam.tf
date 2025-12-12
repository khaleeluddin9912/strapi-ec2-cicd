# iam.tf - CHANGE THE NAME
resource "aws_iam_role" "ec2_ecr_access" {
  name = "ec2-ecr-role-strapi-v3"  # ← CHANGE THIS
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Also update the instance profile name
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile-strapi-v3"  # ← CHANGE THIS TOO
  role = aws_iam_role.ec2_ecr_access.name
}
