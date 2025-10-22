# Get your current public IP
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg-${var.app_bucket_name}"
  description = "Allow traffic for EC2"
  vpc_id      = data.aws_vpc.default.id

  # SSH access only from your current IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }

  # HTTP access from ELB security group on port 8080
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-${var.app_bucket_name}"
  }
}
resource "aws_security_group" "elb_sg" {
  name        = "elb-sg-${var.app_bucket_name}"
  description = "Allow HTTP traffic to ELB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg-${var.app_bucket_name}"
  }
}
