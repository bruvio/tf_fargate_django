

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]




  public_subnets = [
    cidrsubnet(var.vpc_cidr, var.public_subnet_bits, 0),
    cidrsubnet(var.vpc_cidr, var.public_subnet_bits, 1),
    cidrsubnet(var.vpc_cidr, var.public_subnet_bits, 2)
  ]


  private_subnets = [
    cidrsubnet(var.vpc_cidr, var.private_subnet_bits, 3),
    cidrsubnet(var.vpc_cidr, var.private_subnet_bits, 4),
    cidrsubnet(var.vpc_cidr, var.private_subnet_bits, 5)
  ]


  # Example Output

  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true


  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.project}-vpc" })
  )
}

resource "aws_service_discovery_private_dns_namespace" "app" {
  name        = "${var.project}-local"
  description = "${var.project} local zone"
  vpc         = module.vpc.vpc_id
}

