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
    production = ""
    test       = "test"
    dev        = "dev"
    default    = "dev"
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
  default     = "db.m5.large"
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

variable "env" {

}

variable "force_new_deployment" {
  default = "true"
}

variable "enable_deployment_circuit_breaker" {
  type    = bool
  default = true
}
variable "enable_rollback" {
  type    = bool
  default = true
}


variable "allow_public_access" {
  description = "Allow public access (not recommended)"
  type        = bool
  default     = false
}

variable "disable_versioning" {
  description = "Disable versioning on bucket objects."
  type        = bool
  default     = false
}

# Variable for enabling secure transport policy
variable "enable_ssl" {
  description = "Enable or disable secure transport policy."
  type        = bool
  default     = true
}

variable "allow_read" {
  description = "Resources that are allow to read objects."
  type        = list(string)
  default     = []
}

variable "allow_write" {
  description = "Resources that are allow to write to the bucket."
  type        = list(string)
  default     = []
}


variable "tags" {
  description = "bucket tags"
  type        = map(any)
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}


variable "intelligent_tiering" {
  description = "Map containing intelligent tiering configuration."
  type        = any
  default     = {}
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner"
  type        = string
  default     = null
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = any
  default     = {}
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}
variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}


