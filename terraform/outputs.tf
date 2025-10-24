output "clb_dns_name" {
  description = "DNS name of the Classic Load Balancer"
  value       = aws_elb.app_clb.dns_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for JAR files"
  value       = aws_s3_bucket.app_jar_bucket.bucket
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}