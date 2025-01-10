resource "aws_s3_bucket" "app_public_files" {
  bucket        = "${var.project}-${var.bucket_name}"
  force_destroy = var.force_destroy
  # acl           = "public-read"

  tags = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.app_public_files.id
  block_public_acls       = var.allow_public_access ? false : true
  block_public_policy     = var.allow_public_access ? false : true
  ignore_public_acls      = var.allow_public_access ? false : true
  restrict_public_buckets = var.allow_public_access ? false : true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.app_public_files.id

  versioning_configuration {
    status = var.disable_versioning ? "Disabled" : "Enabled"
  }
}
resource "aws_s3_bucket_policy" "app_public_files_policy" {
  bucket = aws_s3_bucket.app_public_files.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.app_public_files.arn}/*"
      }
    ]
  })
}