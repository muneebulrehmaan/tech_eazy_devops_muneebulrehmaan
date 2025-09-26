resource "aws_iam_role" "s3_read_only" {
  name = "s3_read_only"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "s3_read_only_policy"
  description = "Read-only access to S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "read_only_attach" {
  role       = aws_iam_role.s3_read_only.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

resource "aws_iam_role" "s3_write_create" {
  name = "s3_write_create"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_write_create_policy" {
  name        = "s3_write_create_policy"
  description = "Write and Create access to S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:DeleteObject"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "write_policy_attach" {
  role       = aws_iam_role.s3_write_create.name
  policy_arn = aws_iam_policy.s3_write_create_policy.arn
}

resource "aws_iam_instance_profile" "uploader_profile" {
  name = "uploader_profile"
  role = aws_iam_role.s3_write_create.name
}
