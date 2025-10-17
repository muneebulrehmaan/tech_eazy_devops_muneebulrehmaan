output "jar_bucket_name" {
  description = "The name of the S3 bucket for storing the JAR file"
  value       = aws_s3_bucket.jar_bucket.bucket
}

output "ec2_logs_bucket_name" {
  description = "The name of the S3 bucket for EC2 logs"
  value       = aws_s3_bucket.ec2_logs_bucket.bucket
}

output "elb_logs_bucket_name" {
  description = "The name of the S3 bucket for ELB logs"
  value       = aws_s3_bucket.elb_logs_bucket.bucket
}

output "clb_dns_name" {
  description = "DNS name of the Classic Load Balancer"
  value       = aws_elb.app_clb.dns_name
}
