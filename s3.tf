resource "aws_s3_bucket" "app_public_files" {
  bucket        = "${var.prefix}-${var.bucket_name}"
  acl           = "public-read"
  force_destroy = true
}
