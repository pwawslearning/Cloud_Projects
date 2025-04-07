# Create VPC 
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "${var.tags}-vpc"
  }
}

# Create subnets (2public subnets and 2 private subnets)
data "aws_availability_zones" "availabilities" {
    state = "available"
}
resource "aws_subnet" "public_subnet01" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block,8,0)
  availability_zone = data.aws_availability_zones.availabilities.names[0]
  tags = {
    Name = "${var.tags}-public-subnet01"
  }
}
resource "aws_subnet" "public_subnet02" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block,8,1)
  availability_zone = data.aws_availability_zones.availabilities.names[1]
  tags = {
    Name = "${var.tags}-public-subnet02"
  }
}
resource "aws_subnet" "private-subnet01" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block,8,2)
  availability_zone = data.aws_availability_zones.availabilities.names[0]
  tags = {
    Name = "${var.tags}-private-subnet01"
  }
}
resource "aws_subnet" "private-subnet02" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block,8,3)
  availability_zone = data.aws_availability_zones.availabilities.names[1]
  tags = {
    Name = "${var.tags}-private-subnet02"
  }
}

# Create internet gateway and nat gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tags}-igw"
  }
}
resource "aws_eip" "igw-ip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "${var.tags}-eip"
  }
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.igw-ip.id
  subnet_id = aws_subnet.public_subnet02.id
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "${var.tags}-ngw"
  }
}

# Create route tables
resource "aws_route_table" "public-rtb-with-igw" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_routetable"
  }
}
resource "aws_route_table" "rtb-with-natgw" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "private_routetable"
  }
}
resource "aws_route_table_association" "public01-assoc-with-igw" {
  route_table_id = aws_route_table.public-rtb-with-igw.id
  subnet_id = aws_subnet.public_subnet01.id
}
resource "aws_route_table_association" "public02-assoc-with-igw" {
  route_table_id = aws_route_table.public-rtb-with-igw.id
  subnet_id = aws_subnet.public_subnet02.id
}
resource "aws_route_table_association" "private01-assoc-with-natgw" {
  route_table_id = aws_route_table.rtb-with-natgw.id
  subnet_id = aws_subnet.private-subnet01.id
}
resource "aws_route_table_association" "private02-assoc-with-natgw" {
  route_table_id = aws_route_table.rtb-with-natgw.id
  subnet_id = aws_subnet.private-subnet02.id
}

