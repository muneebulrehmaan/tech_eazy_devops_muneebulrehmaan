###############################################
# S3 Buckets for App Artifacts, EC2 Logs, ELB Logs
###############################################

# -------------------------------
# Main Application JAR Bucket
# -------------------------------
resource "aws_s3_bucket" "jar_bucket" {
  bucket = var.app_bucket_name

  tags = {
    Name = var.app_bucket_name
  }
}

# -------------------------------
# EC2 Logs Bucket
# -------------------------------
resource "aws_s3_bucket" "ec2_logs_bucket" {
  bucket = "${var.app_bucket_name}-ec2-logs"

  tags = {
    Name = "${var.app_bucket_name}-ec2-logs"
  }
}

# -------------------------------
# ELB Logs Bucket
# -------------------------------
resource "aws_s3_bucket" "elb_logs_bucket" {
  bucket = "${var.app_bucket_name}-elb-logs"

  tags = {
    Name = "${var.app_bucket_name}-elb-logs"
  }
}

###############################################
# Bucket Public Access Settings
###############################################

# Disable block public access for JAR bucket
resource "aws_s3_bucket_public_access_block" "jar_bucket_block" {
  bucket                  = aws_s3_bucket.jar_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Disable block public access for EC2 logs bucket
resource "aws_s3_bucket_public_access_block" "ec2_logs_bucket_block" {
  bucket                  = aws_s3_bucket.ec2_logs_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Disable block public access for ELB logs bucket
resource "aws_s3_bucket_public_access_block" "elb_logs_bucket_block" {
  bucket                  = aws_s3_bucket.elb_logs_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

###############################################
# Lifecycle Policies (Auto-delete after 7 days)
###############################################

resource "aws_s3_bucket_lifecycle_configuration" "ec2_logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.ec2_logs_bucket.id

  rule {
    id     = "delete-logs-after-7-days"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {}
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "elb_logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.elb_logs_bucket.id

  rule {
    id     = "delete-logs-after-7-days"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {}
  }
}

###############################################
# Bucket Policies
###############################################

# JAR Bucket Policy
resource "aws_s3_bucket_policy" "jar_bucket_policy" {
  bucket = aws_s3_bucket.jar_bucket.id
  policy = templatefile("${path.module}/policy/jar-bucket.json", {
    app_bucket_name = var.app_bucket_name
  })
}

# EC2 Logs Bucket Policy 
resource "aws_s3_bucket_policy" "ec2_logs_bucket_policy" {
  bucket = aws_s3_bucket.ec2_logs_bucket.id
  policy = templatefile("${path.module}/policy/ec2-logs.json", {
    app_bucket_name = var.app_bucket_name
    ec2_logs_bucket = "${var.app_bucket_name}-ec2-logs"
  })
}

# ELB Logs Bucket Policy
resource "aws_s3_bucket_policy" "elb_logs_bucket_policy" {
  bucket = aws_s3_bucket.elb_logs_bucket.id
  policy = templatefile("${path.module}/policy/elb-logs.json", {
    app_bucket_name = var.app_bucket_name
  })
}
