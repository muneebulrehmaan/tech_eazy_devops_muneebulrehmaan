############################################
# IAM Role for EC2
############################################

resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# IAM Policies
############################################

# EC2 can read the JAR file from the S3 app bucket
resource "aws_iam_policy" "jar_bucket_policy" {
  name        = "jar-bucket-policy"
  description = "Allow EC2 to access the app JAR in S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.jar_bucket.arn,
          "${aws_s3_bucket.jar_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_logs_policy" {
  name        = "ec2-logs-policy"
  description = "Allow EC2 to upload logs to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.ec2_logs_bucket.arn}/*"
      }
    ]
  })
}

############################################
# Attach Policies to Role
############################################

resource "aws_iam_role_policy_attachment" "attach_jar_bucket_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.jar_bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ec2_logs_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_logs_policy.arn
}

############################################
# Instance Profile
############################################

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-app-instance-profile"
  role = aws_iam_role.ec2_role.name
}
