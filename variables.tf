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
  default     = 1024
}
variable "memory" {
  description = "ECS Fargate task cpu"
  default     = 2048
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
  default     = true
}

variable "disable_versioning" {
  description = "Disable versioning on bucket objects."
  type        = bool
  default     = false
}
variable "enable_execute_command" {
  description = "whether to enable ssh into container"
  default     = true
}



variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "bypass_shared_password" {
  default = "False"

}
variable "shared_password" {
  default = "secret"
}
variable "engine_version" {
  description = "database engine version"
  default     = 12
}

variable "private" {
  description = "Flag to determine whether to limit access to a specific IP or allow access from anywhere"
  type        = bool
  default     = false
}

variable "my_ip" {
  description = "Your machine's public IP address"
  type        = string
  default     = "YOUR_IP/32" # Replace YOUR_IP with your actual public IP
}

variable "google_maps_api_key" {
  description = "google api key"
}

variable "container_env_vars" {
  description = "A map of environment variables for each container"
  type        = map(map(string))
  default     = {}
}

# Variables for VPC Endpoint Enablement
variable "enable_s3_endpoint" {
  default     = false
  description = "Enable the S3 VPC endpoint"
}

variable "enable_dkr_endpoint" {
  default     = false
  description = "Enable the ECR DKR VPC endpoint"
}

variable "enable_dkr_api_endpoint" {
  default     = false
  description = "Enable the ECR API VPC endpoint"
}

variable "enable_logs_endpoint" {
  default     = false
  description = "Enable the CloudWatch Logs VPC endpoint"
}

variable "enable_secretsmanager_endpoint" {
  default     = false
  description = "Enable the Secrets Manager VPC endpoint"
}

variable "enable_ssm_endpoint" {
  default     = false
  description = "Enable the SSM VPC endpoint"
}

variable "enable_kms_endpoint" {
  default     = false
  description = "Enable the KMS VPC endpoint"
}

variable "public_subnet_bits" {
  default = 3
}

variable "private_subnet_bits" {
  default = 3
}