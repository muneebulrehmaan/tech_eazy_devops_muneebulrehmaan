# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.app_name}-ec2-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-ec2-role"
    Environment = var.environment
  }
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.app_name}-ec2-instance-profile-${var.environment}"
  role = aws_iam_role.ec2_role.name
}

# Attach policies to the role
resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.app_name}-s3-policy-${var.environment}"
  role = aws_iam_role.ec2_role.id

  policy = templatefile("${path.module}/policy/jar-bucket.json", {
    s3_bucket = aws_s3_bucket.app_jar_bucket.bucket
  })
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "${var.app_name}-cloudwatch-policy-${var.environment}"
  role = aws_iam_role.ec2_role.id

  policy = templatefile("${path.module}/policy/cloudwatch.json", {
    app_name = var.app_name
  })
}

resource "aws_iam_role_policy" "autoscaling_policy" {
  name = "${var.app_name}-autoscaling-policy-${var.environment}"
  role = aws_iam_role.ec2_role.id

  policy = file("${path.module}/policy/ec2-scale.json")
}

# Attach AWS managed policies for additional permissions
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_core_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}