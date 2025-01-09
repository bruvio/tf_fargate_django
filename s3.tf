resource "aws_s3_bucket" "app_public_files" {
  bucket        = "${var.project}-${var.bucket_name}"
  force_destroy = true
  # acl           = "public-read"

  tags = var.common_tags
}

# IAM Policy for S3

resource "aws_iam_policy" "ecs_s3_access" {
  name        = "${var.project}-AppS3AccessPolicy"
  path        = "/"
  description = "Allow access to the traffic app S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "${aws_s3_bucket.app_public_files.arn}/*",
          "${aws_s3_bucket.app_public_files.arn}"
        ]
      }
    ]
  })
}
