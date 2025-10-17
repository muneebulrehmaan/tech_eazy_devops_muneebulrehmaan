
#############################################
# Variable Definitions for EC2 + CLB Setup
#############################################

# S3 bucket name for the app JAR
variable "app_bucket_name" {
  description = "S3 bucket name for the application JAR"
  type        = string
  default     = "balteen121"
}

# Instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# AWS region
variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "ap-south-1"
}

# Name of the application JAR stored in S3
variable "jar_name" {
  description = "JAR filename to be downloaded from S3 bucket"
  type        = string
  default     = "hellomvc-0.0.1-SNAPSHOT.jar"
}

variable "ec2_logs_bucket" {
  description = "S3 bucket name where EC2 instances can push logs (optional)"
  type        = string
  default     = "balteen-ec2-logs"
}
