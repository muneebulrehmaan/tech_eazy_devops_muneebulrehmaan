resource "aws_s3_bucket" "logs" {
  bucket = "balteen-logs-bucket"
}

resource "aws_s3_bucket_ownership_controls" "logs_ownership" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "logs_block" {
  bucket = aws_s3_bucket.logs.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}
