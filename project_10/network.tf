data "aws_availability_zones" "available" {
state = "available"
}
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block[0]
  instance_tenancy = "default"

  tags = {
    Name = "${var.tags}-vpc"
  }
}
resource "aws_subnet" "public-subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block[0],8,0)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public-subnet1"
  }
}
resource "aws_subnet" "public-subnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block[0],8,1)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public-subnet2"
  }
}
resource "aws_subnet" "private-subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block[0],8,2)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private-subnet1"
  }
}
resource "aws_subnet" "private-subnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block[0],8,3)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private-subnet2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tags}-igw"
  }
}
resource "aws_eip" "ngw-eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "${var.tags}-eip"
  }
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id = aws_subnet.public-subnet1.id
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "${var.tags}-ngw"
  }
}
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}
resource "aws_route_table_association" "public-rt-assoc-1" {
  subnet_id = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_route_table_association" "public-rt-assoc-2" {
  subnet_id = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_route_table_association" "private-rt-assoc-1" {
  subnet_id = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private_rtb.id
}
resource "aws_route_table_association" "private-rt-assoc-2" {
  subnet_id = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private_rtb.id
}