###################################################################################################
############################################ VPC CONFIG ###########################################
###################################################################################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.network_tag,
    {
      Type = "VPC"
    }
  )
}

########  Internet GW  ########
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.network_tag,
    {
      Type = "IGW"
    }
  )

  depends_on = [aws_vpc.main]
}

########  Setting UP Subnets  ########
resource "aws_subnet" "subnets" {
  for_each          = local.actual_subnets_data
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    var.network_tag,
    {
      Name = each.value.name,
      Type = "Subnet"
    }
  )

  depends_on = [aws_vpc.main]
}

###################################################################################################
########  Setting UP Routing Tables  ########
###################################################################################################
########  Public RT  ########
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.default
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.network_tag,
    {
      Type = "Route_Table",
      Name = "Public_RT"
    }
  )

  depends_on = [aws_internet_gateway.gw]
}

########  Private RT  ########
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.network_tag,
    {
      Type = "Route_Table",
      Name = "Private_RT"
    }
  )

}

########  RT Mapping  ########
locals {
  rt_list = {
    "public_a"  = aws_route_table.public_rt.id,
    "public_b"  = aws_route_table.public_rt.id,
    "private_a" = aws_route_table.private_rt.id,
    "private_b" = aws_route_table.private_rt.id
  }
}

########  Subnet Association with RT  ########
resource "aws_route_table_association" "subnets_associations" {
  for_each       = aws_subnet.subnets
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = local.rt_list[each.key]

  depends_on = [aws_vpc.main]
}
