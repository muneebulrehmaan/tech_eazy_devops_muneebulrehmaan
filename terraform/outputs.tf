output "app_server_public_ips" {
  value = aws_instance.app_server[*].public_ip
}

output "clb_dns_name" {
  description = "DNS name of the Classic Load Balancer"
  value       = aws_elb.app_clb.dns_name
}

output "elb_logs_bucket" {
  description = "S3 bucket for ELB access logs"
  value       = aws_s3_bucket.elb_logs_bucket.bucket
}
