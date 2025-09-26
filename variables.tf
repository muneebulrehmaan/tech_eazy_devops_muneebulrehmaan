<<<<<<< HEAD
variable "aws_region" {
  type    = string
  default = "ap-south-1"
  description = "AWS region (default ap-south-1)"
}

# REQUIRED: no default => terraform will error if not provided
variable "bucket_name" {
  type        = string
  description = "S3 bucket name (required). If not provided, terraform will fail."
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
# Optional: SSH key (empty = no ssh)
variable "key_pair_name" {
  type    = string
  default = ""
  description = "Optional existing keypair name for EC2 SSH. Leave empty for none."
}
=======
variable "aws_region" {
  type    = string
  default = "ap-south-1"
  description = "AWS region (default ap-south-1)"
}

# REQUIRED: no default => terraform will error if not provided
variable "bucket_name" {
  type        = string
  description = "S3 bucket name (required). If not provided, terraform will fail."
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
# Optional: SSH key (empty = no ssh)
variable "key_pair_name" {
  type    = string
  default = ""
  description = "Optional existing keypair name for EC2 SSH. Leave empty for none."
}
>>>>>>> 049dcd7118c26d6f34811de6e7f6c4c092c07c97
