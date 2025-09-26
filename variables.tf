variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region (default ap-south-1)"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name (required). If not provided, terraform will fail."
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_pair_name" {
  type        = string
  default     = ""
  description = "Optional existing keypair name for EC2 SSH. Leave empty for none."
}