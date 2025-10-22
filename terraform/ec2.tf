############################################
# ec2.tf
# EC2 Auto Scaling Group (ASG) + Launch Template + CloudWatch Log Group
############################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_key_pair" "default" {
  key_name = "mykey"
}


############################################
# CloudWatch Log Group
############################################
resource "aws_cloudwatch_log_group" "asg_log_group" {
  name              = "/aws/asg/${var.app_bucket_name}-logs"
  retention_in_days = 7
}

############################################
# Launch Template
############################################
resource "aws_launch_template" "app_server_lt" {
  name_prefix   = "${var.app_bucket_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.default.key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id] # This references the correct SG
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/../scripts/ec2/user-data.sh.tpl", {
    app_bucket_name = var.app_bucket_name
    JAR_NAME        = var.jar_name != "" ? var.jar_name : "hellomvc-0.0.1-SNAPSHOT.jar"
    APP_PATH        = "/home/ec2-user/${var.jar_name != "" ? var.jar_name : "hellomvc-0.0.1-SNAPSHOT.jar"}"
    LOG_PATH        = "/home/ec2-user/app.log"
    REGION          = var.aws_region
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.app_bucket_name}-AppServer"
    }
  }
}

############################################
# Optional: Output CloudWatch Log Group name
############################################
output "asg_log_group_name" {
  value = aws_cloudwatch_log_group.asg_log_group.name
}
