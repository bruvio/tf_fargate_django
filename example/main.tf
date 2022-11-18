# terraform {
#   backend "s3" {
#     bucket         = "bucket"
#     key            = ".tfstate"
#     region         = "us-east=1"
#     encrypt        = true
#     dynamodb_table = "table"
#   }
# }


terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}


locals {
  contact = "<chooseme>"
  project = "<chooseme>"
  region  = "us-east-1"
  prefix  = "<chooseme>-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = local.project
    Owner       = local.contact
    ManagedBy   = "Terraform"
  }


}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


module "this" {
  source            = "git@github.com:bruvio/tf_fargate_django.git?ref=feature/endpoints"
  project           = local.project
  admin             = var.admin
  table_name        = var.table_name
  db_username       = var.db_username
  db_password       = var.db_password
  django_secret_key = var.django_secret_key
  admin_password    = var.admin_password
  admin_email       = var.admin_email
  state_bucket      = var.state_bucket
  dns_zone_name     = var.dns_zone_name
  ecr_image_proxy   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.project}-proxy:latest"
  ecr_image_api     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.project}:latest"
  contact           = local.contact
  prefix            = local.prefix
  bastion_key_name  = var.bastion_key_name
  db_name           = var.db_name
  bucket_name       = var.bucket_name
  region            = local.region
  common_tags       = local.common_tags

}
