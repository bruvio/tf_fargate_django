#tfsec:ignore:aws-ecr-enforce-immutable-repository
resource "aws_ecr_repository" "app" {
  name                 = var.project
  image_tag_mutability = "MUTABLE"
  tags                 = var.common_tags
  # count                = var.vpc_name == "dev" ? 1 : 0

  image_scanning_configuration {
    scan_on_push = true
  }
}

# data "aws_ecr_image" "app" {
#   repository_name = var.project
#   image_tag       = "latest"
# }


resource "aws_ecr_repository" "proxy" {
  name                 = "${var.project}-proxy"
  image_tag_mutability = "MUTABLE"
  tags                 = var.common_tags
  # count                = var.vpc_name == "dev" ? 1 : 0

  image_scanning_configuration {
    scan_on_push = true
  }
}

# data "aws_ecr_image" "proxy" {
#   repository_name = "${var.project}-proxy"
#   image_tag       = "latest"
# }

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "proxy" {
  repository = aws_ecr_repository.proxy.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}