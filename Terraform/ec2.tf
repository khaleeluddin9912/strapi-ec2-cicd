resource "aws_key_pair" "strapi_key" {
  key_name   = var.key_name
  public_key = file("${path.cwd}/${var.key_name}.pub")
}

resource "aws_instance" "strapi_ec2" {
  ami                         = "ami-02b8269d5e85954ef"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.strapi_key.key_name
  security_groups             = [aws_security_group.strapi_sg.name]
  associate_public_ip_address = true

  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("user-data.sh.tpl", {
    image_tag = var.image_tag,
    ecr_repo  = var.ecr_repo
  })

  tags = {
    Name = "Strapi-EC2"
  }
}

