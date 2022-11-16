
# VPC Endpoint Security Group

resource "aws_security_group" "vpc_endpoint" {
  name   = "${local.prefix}-vpce-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-sg-vpc-endpoint" })
  )

}

# VPC Endpoints

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-s3-endpoint" })
  )

}

resource "aws_vpc_endpoint" "dkr" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = module.vpc.private_subnets
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-dkr-endpoint" })
  )

}

resource "aws_vpc_endpoint" "dkr_api" {
  vpc_id              = module.vpc.vpc_id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = module.vpc.private_subnets
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-dkr-api-endpoint" })
  )

}

resource "aws_vpc_endpoint" "logs" {
  vpc_id = module.vpc.vpc_id

  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = module.vpc.private_subnets
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-logs-endpoint" })
  )

}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id = module.vpc.vpc_id

  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = module.vpc.private_subnets
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-secretsmanager-endpoint" })
  )

}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id = module.vpc.vpc_id

  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = module.vpc.private_subnets
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-ssm-endpoint" })
  )

}

resource "aws_vpc_endpoint" "kms" {
  vpc_id = module.vpc.vpc_id

  private_dns_enabled = true
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [
    aws_security_group.vpc_endpoint.id,
  ]
  subnet_ids = module.vpc.private_subnets
  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-kms-endpoint" })
  )

}
