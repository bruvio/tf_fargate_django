variable "prefix" {
  description = "project prefix"
}
variable "project" {
  description = "project name"
}

variable "contact" {
  description = "email contact"
}
variable "db_name" {
  description = "name of db"
}
variable "db_username" {
  description = "username for RDS postgrase database"
}
variable "db_password" {
  description = "password for RDS postgrase database"
}
variable "bastion_key_name" {
}

variable "ecr_image_api" {
  description = "ECR Image for API"

}

variable "ecr_image_proxy" {
  description = "ECR Image for API"

}

variable "django_secret_key" {
  description = "Secret key for the Django app"
}
variable "admin" {
  description = "admin name"
}
variable "admin_email" {
  description = "Admin email"
}
variable "admin_password" {
  description = "password for admin"
}

variable "dns_zone_name" {
  description = "Domain name"
}

variable "subdomain" {
  description = "Subdomain per environment"
  type        = map(string)
  default = {
    production = "api"
    staging    = "api.staging"
    dev        = "api.dev"
    default    = "api.dev"
  }
}

variable "state_bucket" {
  type = string

}
variable "region" {
  description = "aws region"
  type        = string
  # default = "us-east-1"
}
variable "bucket_name" {

}

variable "table_name" {
  description = "The name of the DynamoDB table. Must be unique in this AWS account."
  type        = string
  # default = "terraform-setup-tf-state-lock"
}
variable "common_tags" {
  default = {
    Environment = ""
    Project     = ""
    Owner       = ""
    ManagedBy   = "Terraform"
  }
}

variable "cpu" {
  description = "ECS Fargate task cpu"
  default     = 256
}
variable "memory" {
  description = "ECS Fargate task cpu"
  default     = 512
}


variable "rds_storage" {
  default     = 5
  description = "RDS storage"
}
variable "rds_instance" {
  default     = "db.t2.micro"
  description = "RDS instance class"
}
variable "bastion_instance" {
  default     = "t2.micro"
  description = "bastion host EC2 instance class"
}
variable "az_count" {
  description = "numbero of availability zones"
  default     = 2
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
} 