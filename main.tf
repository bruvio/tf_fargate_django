
provider "aws" {
  region = var.region
}
locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = "${var.project}"
    Owner       = "${var.contact}"
    ManagedBy   = "Terraform"
  }

vpc_cidr = "10.0.0.0/16"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


