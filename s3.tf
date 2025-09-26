<<<<<<< HEAD
resource "aws_s3_bucket" "logs" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "logs-bucket"
  }
}

# Enforce bucket owner ownership (disables ACLs)
resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block public access (recommended security)
resource "aws_s3_bucket_public_access_block" "logs_block" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule for log expiry
resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {
      prefix = "" # applies to all objects
    }
  }
}
=======
resource "aws_s3_bucket" "logs" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "logs-bucket"
  }
}

# Enforce bucket owner ownership (disables ACLs)
resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block public access (recommended security)
resource "aws_s3_bucket_public_access_block" "logs_block" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule for log expiry
resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {
      prefix = "" # applies to all objects
    }
  }
}
>>>>>>> 049dcd7118c26d6f34811de6e7f6c4c092c07c97
