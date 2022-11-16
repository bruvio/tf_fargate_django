

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.prefix}-vpc"
  cidr = local.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  enable_vpn_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true


    tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-bastion" })
  )
}

resource "aws_service_discovery_private_dns_namespace" "app" {
  name        = "${var.prefix}-local"
  description = "${var.prefix} local zone"
  vpc         = module.vpc.vpc_id
}
