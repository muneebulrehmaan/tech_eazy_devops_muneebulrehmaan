<<<<<<< HEAD
output "s3_read_only_role_arn" {
  value = aws_iam_role.s3_read_only.arn
}

output "s3_write_role_arn" {
  value = aws_iam_role.s3_write_create.arn
}


output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.uploader.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.uploader.public_ip
}

output "private_key_path" {
  value = local_file.private_key_pem.filename
  description = "Path to the generated private key file"
}

=======
output "s3_read_only_role_arn" {
  value = aws_iam_role.s3_read_only.arn
}

output "s3_write_role_arn" {
  value = aws_iam_role.s3_write_create.arn
}


output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.uploader.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.uploader.public_ip
}

output "private_key_path" {
  value = local_file.private_key_pem.filename
  description = "Path to the generated private key file"
}

>>>>>>> 049dcd7118c26d6f34811de6e7f6c4c092c07c97
