###################################################################################################
############################################ VPC CONFIG ###########################################
###################################################################################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    name = "Main_VPC"
  }
}

########  Internet GW  ########
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "RDS_IGW"
  }

  depends_on = [aws_vpc.main]
}

########  Setting UP Subnets  ########
resource "aws_subnet" "subnets" {
  for_each          = local.actual_subnets_data
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.value.name
  }

  depends_on = [aws_vpc.main]
}
###################################################################################################
########  Setting UP NAT GW  ########
###################################################################################################
########  Allocating Network Interfaces for NAT GW  ########
#resource "aws_eip" "nat" {
#  tags = {
#    Name = "External_NAT_GW"
#  }
#}

########  Create NAT GW  ########
#resource "aws_nat_gateway" "nat_gateway" {
#  allocation_id = aws_eip.nat.id
#  subnet_id     = aws_subnet.subnets["public_rds_a"].id

#  tags = {
#    Name = "NAT Gateway"
#  }

#  depends_on = [aws_vpc.main]
#}

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

  tags = {
    Name = "Public_RT"
  }

  depends_on = [aws_internet_gateway.gw]
}

########  Private RT  ########
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

#  route {
#    cidr_block = var.default
#    gateway_id = aws_nat_gateway.nat_gateway.id
#  }

  tags = {
    Name = "Private_RT"
  }

#  depends_on = [aws_nat_gateway.nat_gateway]
}

########  Inner RT  ########
resource "aws_route_table" "inner_rt" {
  vpc_id = aws_vpc.main.id


  tags = {
    Name = "Inner_RT"
  }

  depends_on = [aws_vpc.main]
}

########  RT Mapping  ########
locals {
  rt_list = {
    "public_rds_a"  = aws_route_table.public_rt.id,
    "public_rds_b"  = aws_route_table.public_rt.id,
    "private_rds_a" = aws_route_table.private_rt.id,
    "private_rds_b" = aws_route_table.private_rt.id,
    "inner_rds_a"   = aws_route_table.inner_rt.id,
    "inner_rds_b"   = aws_route_table.inner_rt.id,
  }
}

########  Subnet Association with RT  ########
resource "aws_route_table_association" "subnets_associations" {
  for_each       = aws_subnet.subnets
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = local.rt_list[each.key]

  depends_on = [aws_vpc.main]
}

