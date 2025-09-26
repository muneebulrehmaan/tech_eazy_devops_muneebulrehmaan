<<<<<<< HEAD
resource "aws_iam_role" "s3_read_only" {
  name = "s3-read-only-role"

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

resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "s3-read-only-policy"
  description = "Allows listing and reading objects from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "read_only_attach" {
  role       = aws_iam_role.s3_read_only.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

resource "aws_iam_role" "s3_write_create" {
  name = "s3-write-create-role"

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

resource "aws_iam_policy" "s3_write_create_policy" {
  name        = "s3-write-create-policy"
  description = "Allows creating buckets and uploading objects to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "write_policy_attach" {
  role       = aws_iam_role.s3_write_create.name
  policy_arn = aws_iam_policy.s3_write_create_policy.arn
}

resource "aws_iam_instance_profile" "uploader_profile" {
  name = "uploader-instance-profile"
  role = aws_iam_role.s3_write_create.name
}
=======
resource "aws_iam_role" "s3_read_only" {
  name = "s3-read-only-role"

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

resource "aws_iam_policy" "s3_read_only_policy" {
  name        = "s3-read-only-policy"
  description = "Allows listing and reading objects from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "read_only_attach" {
  role       = aws_iam_role.s3_read_only.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

resource "aws_iam_role" "s3_write_create" {
  name = "s3-write-create-role"

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

resource "aws_iam_policy" "s3_write_create_policy" {
  name        = "s3-write-create-policy"
  description = "Allows creating buckets and uploading objects to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "write_policy_attach" {
  role       = aws_iam_role.s3_write_create.name
  policy_arn = aws_iam_policy.s3_write_create_policy.arn
}

resource "aws_iam_instance_profile" "uploader_profile" {
  name = "uploader-instance-profile"
  role = aws_iam_role.s3_write_create.name
}
>>>>>>> 049dcd7118c26d6f34811de6e7f6c4c092c07c97
