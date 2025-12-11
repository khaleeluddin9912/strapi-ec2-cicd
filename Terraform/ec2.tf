resource "aws_key_pair" "strapi_key" {
  key_name   = var.key_name
  public_key = file("${path.cwd}/${var.key_name}.pub")
}

resource "aws_instance" "strapi_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.strapi_key.key_name
  security_groups        = [aws_security_group.strapi_sg.name]
  associate_public_ip_address = true
  user_data              = templatefile("user-data.sh", { image_tag = var.image_tag })

  tags = {
    Name = "Strapi-EC2"
  }
}
