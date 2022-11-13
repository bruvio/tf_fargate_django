resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-vpc" })
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-main" })

  )
}
#####################################################
# Public Subnets - Inbound/Outbound Internet Access #
#####################################################
resource "aws_subnet" "public_a" {
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.region}a"

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-public-a" })
  )
}

resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-public-a" })
  )
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route" "public_internet_access_a" {
  route_table_id         = aws_route_table.public_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# resource "aws_eip" "public_a" {
#   count = var.enable_nat_elastic-ip == true ? 1 : 0
#   vpc   = true

#   tags = merge(
#     var.common_tags,
#     tomap({ "Name" = "${var.prefix}-public-a" })
#   )
# }

# resource "aws_nat_gateway" "public_a" {
#   count         = var.enable_nat_elastic-ip == true ? 1 : 0
#   allocation_id = aws_eip.public_a[0].id
#   subnet_id     = aws_subnet.public_a.id

#   tags = merge(
#     var.common_tags,
#     tomap({ "Name" = "${var.prefix}-public-a" })
#   )
# }

resource "aws_subnet" "public_b" {
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.region}b"

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-public-b" })
  )
}

resource "aws_route_table" "public_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-public-b" })
  )
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_b.id
}

resource "aws_route" "public_internet_access_b" {
  route_table_id         = aws_route_table.public_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# resource "aws_eip" "public_b" {
#   count = var.enable_nat_elastic-ip == true ? 1 : 0
#   vpc   = true

#   tags = merge(
#     var.common_tags,
#     tomap({ "Name" = "${var.prefix}-public-b" })
#   )
# }

# resource "aws_nat_gateway" "public_b" {
#   count         = var.enable_nat_elastic_ip == true ? 1 : 0
#   allocation_id = aws_eip.public_b[0].id
#   subnet_id     = aws_subnet.public_b.id

#   tags = merge(
#     var.common_tags,
#     tomap({ "Name" = "${var.prefix}-public-b" })
#   )
# }


##################################################
# Private Subnets - Outbound internt access only #
##################################################
resource "aws_subnet" "private_a" {
  cidr_block        = "10.1.10.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}a"

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-private-a" })
  )
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-private-a" })
  )
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# resource "aws_route" "private_a_internet_out" {
#   route_table_id         = aws_route_table.private_a.id
#   nat_gateway_id         = aws_nat_gateway.public_a[0].id
#   destination_cidr_block = "0.0.0.0/0"
# }

resource "aws_subnet" "private_b" {
  cidr_block        = "10.1.11.0/24"
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.region}b"

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-private-b" })
  )
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-private-b" })
  )
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

# resource "aws_route" "private_b_internet_out" {
#   route_table_id         = aws_route_table.private_b.id
#   nat_gateway_id         = aws_nat_gateway.public_b[0].id
#   destination_cidr_block = "0.0.0.0/0"
# }
