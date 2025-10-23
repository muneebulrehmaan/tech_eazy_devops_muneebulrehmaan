# Keep only the JAR bucket, remove ELB logs bucket
resource "aws_s3_bucket" "app_jar_bucket" {
  bucket = "${var.app_name}-${var.environment}-jar-bucket"
  
  tags = {
    Name        = "${var.app_name}-jar-bucket"
    Environment = var.environment
  }
}

# Remove all ELB logs bucket resources
# Remove: aws_s3_bucket.elb_logs_bucket
# Remove: aws_s3_bucket_policy.elb_logs_policy
# Remove: aws_s3_bucket_versioning.elb_logs_versioning

# Keep ownership controls for JAR bucket
resource "aws_s3_bucket_ownership_controls" "jar_bucket_ownership" {
  bucket = aws_s3_bucket.app_jar_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Keep public access block for JAR bucket
resource "aws_s3_bucket_public_access_block" "app_jar_bucket_block" {
  bucket = aws_s3_bucket.app_jar_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}