# sg.tf - Security Group for Strapi EC2

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi_sg"
  description = "Security group for Strapi EC2"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP for Strapi (port 1337)
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "StrapiSG"
  }
}
