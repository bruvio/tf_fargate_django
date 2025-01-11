terraform {
  backend "s3" {
    key     = "<project>/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

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
  project = var.project
  region  = data.aws_region.current.name
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
  source            = "git@github.com:bruvio/tf_fargate_django.git"
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
  # ecr_image_proxy   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.project}-proxy:${var.service_version}"
  ecr_image_proxy  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.project}-proxy:0b20e15"
  ecr_image_api    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.project}:${var.service_version}"
  contact          = local.contact
  prefix           = var.prefix
  bastion_key_name = var.bastion_key_name
  db_name          = var.db_name
  bucket_name      = var.bucket_name
  region           = local.region
  common_tags      = local.common_tags
  env              = var.env

}
