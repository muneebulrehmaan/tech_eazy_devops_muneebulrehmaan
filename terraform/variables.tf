
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

# Number of EC2 instances (for load balancing)
variable "instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
  default     = 2
}

# AWS region
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}
