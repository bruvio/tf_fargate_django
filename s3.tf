resource "aws_s3_bucket" "app_public_files" {
  bucket        = "${var.project}-${var.bucket_name}"
  force_destroy = true
  # acl           = "public-read"

  tags = var.common_tags
}