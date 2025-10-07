data "aws_key_pair" "default" {
  key_name = "mykey"
}

resource "aws_instance" "app_server" {
  count                       = var.instance_count
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.default.key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/../scripts/ec2/user-data.sh.tpl", {
    app_bucket_name = var.app_bucket_name
    JAR_NAME        = "hellomvc-0.0.1-SNAPSHOT.jar"
    APP_PATH        = "/home/ec2-user/hellomvc-0.0.1-SNAPSHOT.jar"
    LOG_PATH        = "/home/ec2-user/app.log"
  })

  tags = {
    Name = "${var.app_bucket_name}-AppServer-${count.index}"
  }
}



