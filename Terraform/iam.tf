resource "aws_iam_role" "ec2_ecr_access" {
  name = "ec2-ecr-role-finals"    # 🔥 changed name to avoid duplicate error

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

resource "aws_iam_role_policy_attachment" "ecr_attach" {
  role       = aws_iam_role.ec2_ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile-finals"   # 🔥 changed to avoid duplicate error
  role = aws_iam_role.ec2_ecr_access.name
}
