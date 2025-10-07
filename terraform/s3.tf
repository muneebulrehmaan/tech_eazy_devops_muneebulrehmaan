
# -------------------------------
# S3 Buckets for App, EC2 Logs, ELB Logs
# -------------------------------

resource "aws_s3_bucket" "jar_bucket" {
  bucket = var.app_bucket_name

  tags = {
    Name = var.app_bucket_name
  }
}

resource "aws_s3_bucket" "ec2_logs_bucket" {
  bucket = "${var.app_bucket_name}-ec2-logs"

  tags = {
    Name = "${var.app_bucket_name}-ec2-logs"
  }
}

resource "aws_s3_bucket" "elb_logs_bucket" {
  bucket = "${var.app_bucket_name}-elb-logs"

  tags = {
    Name = "${var.app_bucket_name}-elb-logs"
  }
}
# -------------------------------
# Attach Bucket Policies
# -------------------------------

resource "aws_s3_bucket_policy" "jar_bucket_policy" {
  bucket = aws_s3_bucket.jar_bucket.id
  policy = templatefile("${path.module}/policy/jar-bucket.json", {
    app_bucket_name = var.app_bucket_name
  })
}

resource "aws_s3_bucket_policy" "ec2_logs_bucket_policy" {
  bucket = aws_s3_bucket.ec2_logs_bucket.id
  policy = templatefile("${path.module}/policy/ec2-logs.json", {
    app_bucket_name = var.app_bucket_name
  })
}

resource "aws_s3_bucket_policy" "elb_logs_bucket_policy" {
  bucket = aws_s3_bucket.elb_logs_bucket.id
  policy = templatefile("${path.module}/policy/elb-logs.json", {
    app_bucket_name = var.app_bucket_name
  })
}
