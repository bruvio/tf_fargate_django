#tfsec:ignore:aws-ecr-enforce-immutable-repository
resource "aws_ecr_repository" "default" {
  name                 = var.project
  image_tag_mutability = "MUTABLE"
  tags                 = var.common_tags
  # count                = var.vpc_name == "dev" ? 1 : 0

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_image" "default" {
  repository_name = var.project
  image_tag       = "latest"
}