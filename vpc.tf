

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  # Use the specified number of AZs, but ensure it is less than or equal to available AZs
  azs = slice(data.aws_availability_zones.available.names, 0, var.num_azs)

  # Create public subnets, one per AZ
  public_subnets = [
    for i in range(var.num_azs) : cidrsubnet(var.vpc_cidr, var.public_subnet_bits, i)
  ]

  # Create private subnets, one per AZ
  private_subnets = [
    for i in range(var.num_azs) : cidrsubnet(var.vpc_cidr, var.private_subnet_bits, var.num_azs + i)
  ]

  # NAT configuration
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false

  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.project}-vpc" })
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_service_discovery_private_dns_namespace" "app" {
  name        = "${var.project}-local"
  description = "${var.project} local zone"
  vpc         = module.vpc.vpc_id
}

