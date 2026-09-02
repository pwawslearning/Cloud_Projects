# VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count = var.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index) # 10.0.0.0/24, 10.0.1.0/24
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public_subnet0${count.index + 1}"
    Type = "public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count = var.private_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, 2 + count.index) # 10.0.2.0/24, 10.0.3.0/24
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-private_subnet0${count.index + 1}"
    Type = "private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "natgwip" {
  count  = var.eip_count
  domain = "vpc"

  tags = {
    Name = "${var.project}-natgwip${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gw" {
  count         = var.natgw_count
  allocation_id = aws_eip.natgwip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project}-natgw${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route tables

# Public Route table

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count          = var.public_subnets
  route_table_id = aws_route_table.pub_rt.id
  subnet_id      = aws_subnet.public[count.index].id
}

# Private Route table

resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[0].id
  }

  tags = {
    Name = "${var.project}-pri-rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count          = var.private_subnets
  route_table_id = aws_route_table.pri_rt.id
  subnet_id      = aws_subnet.private[count.index].id
}
