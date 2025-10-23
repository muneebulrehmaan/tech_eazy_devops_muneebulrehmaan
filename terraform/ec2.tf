# Launch template for ASG
resource "aws_launch_template" "app_lt" {
  name          = "${var.app_name}-lt"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/user-data.sh", {
    S3_BUCKET = aws_s3_bucket.app_jar_bucket.bucket
    JAR_FILE  = var.jar_file_name
    APP_NAME  = var.app_name
    REGION    = var.aws_region
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.app_name}-instance"
      Environment = var.environment
    }
  }

  tags = {
    Name        = "${var.app_name}-launch-template"
    Environment = var.environment
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}