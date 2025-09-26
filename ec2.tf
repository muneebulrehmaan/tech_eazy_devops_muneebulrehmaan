resource "aws_key_pair" "generated_key" {
  key_name   = "mykey"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "${path.module}/mykey.pem"
}

resource "aws_instance" "uploader" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.uploader_profile.name
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    bucket_name = var.bucket_name
  })

  tags = {
    Name = "uploader-instance"
  }
}