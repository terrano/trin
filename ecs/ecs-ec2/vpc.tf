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
      uid  = var.prj_id
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
      uid  = var.prj_id
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
      uid  = var.prj_id
      Name = each.value.name
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
      uid  = var.prj_id
      Type = "Route_Table"
      Name = "Public_RT"
    }
  )

  depends_on = [aws_internet_gateway.gw]
}

########  RT Mapping  ########
locals {
  rt_list = {
    "public_a" = aws_route_table.public_rt.id,
    "public_b" = aws_route_table.public_rt.id
  }
}

########  Subnet Association with RT  ########
resource "aws_route_table_association" "subnets_associations" {
  for_each       = aws_subnet.subnets
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = local.rt_list[each.key]

  depends_on = [aws_vpc.main]
}

###################################################################################################
########################################### SSM ENDPOINTS #########################################
###################################################################################################
resource "aws_vpc_endpoint" "ssm" {
  for_each          = var.region_config["${var.region}"].ssm_endpoints
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id
  ]

  security_group_ids = [aws_security_group.permit_internal.id]

  private_dns_enabled = true

  tags = merge(
    var.network_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "SSM_Communication"])
      Type = "Endpoint"
    }
  )
}

###################################################################################################
########################################### ECR ENDPOINTS #########################################
###################################################################################################
resource "aws_vpc_endpoint" "ecr_api" {
  for_each          = var.region_config["${var.region}"].ecr_endpoints
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id
  ]

  security_group_ids = [aws_security_group.permit_internal.id]

  private_dns_enabled = true

  tags = merge(
    var.network_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "ECR_Communication"])
      Type = "Endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "ecr_s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = var.region_config["${var.region}"].ecr_s3_endpoint
  vpc_endpoint_type = "Gateway"

  tags = merge(
    var.network_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "S3_Communication"])
      Type = "Endpoint"
    }
  )
}

resource "aws_vpc_endpoint_route_table_association" "ecr_s3_rt" {
  route_table_id  = aws_route_table.public_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.ecr_s3.id
}

###################################################################################################
########################################### ECS ENDPOINT ##########################################
###################################################################################################
resource "aws_vpc_endpoint" "ecs_api" {
  for_each          = var.region_config["${var.region}"].ecs_endpoints
  vpc_id            = aws_vpc.main.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.subnets["public_a"].id, aws_subnet.subnets["public_b"].id
  ]

  security_group_ids = [aws_security_group.permit_internal.id]

  private_dns_enabled = true

  tags = merge(
    var.network_tag,
    {
      uid  = var.prj_id
      Name = join("-", ["${local.prj_full_name}", "ECS_Communication"])
      Type = "Endpoint"
    }
  )
}