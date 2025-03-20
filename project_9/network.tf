resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"
  provider         = aws.ap-southeast-1

  tags = {
    Name = "vpc-1"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/26"
  depends_on = [ aws_vpc.vpc1 ]
  provider = aws.ap-southeast-1
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "subnet-1"
  }
}
resource "aws_vpc" "vpc2" {
  cidr_block       = "192.168.0.0/24"
  instance_tenancy = "default"
  provider         = aws.ap-southeast-2

  tags = {
    Name = "vpc-2"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "192.168.0.0/26"
  provider = aws.ap-southeast-2
  depends_on = [ aws_vpc.vpc2 ]
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "subnet-2"
  }
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.vpc1.id
  provider = aws.ap-southeast-1

  tags = {
    Name = "vpc1-gw1"
  }
}
resource "aws_internet_gateway" "gw2" {
  vpc_id = aws_vpc.vpc2.id
  provider = aws.ap-southeast-2

  tags = {
    Name = "vpc2-gw2"
  }
}


resource "aws_vpc_peering_connection" "peer1" {
  peer_vpc_id   = aws_vpc.vpc2.id
  vpc_id        = aws_vpc.vpc1.id
  auto_accept = false
  provider = aws.ap-southeast-1
  peer_region = "ap-southeast-2"

  tags = {
    Name = "vpc1_to_vpc2"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer2" {
  provider                  = aws.ap-southeast-2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  auto_accept               = true

  tags = {
    Side = "vpc2_to_vpc1"
  }
}
resource "aws_route_table" "vpc1-rtb" {
  vpc_id = aws_vpc.vpc1.id
  provider = aws.ap-southeast-1
}
resource "aws_route_table" "vpc2-rtb" {
  vpc_id = aws_vpc.vpc2.id
  provider = aws.ap-southeast-2
}
resource "aws_route" "route1" {
  route_table_id = aws_route_table.vpc1-rtb.id
  destination_cidr_block = "192.168.0.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer2.id
  provider = aws.ap-southeast-1
}
resource "aws_route" "route1-int" {
  route_table_id = aws_route_table.vpc1-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw1.id
  provider = aws.ap-southeast-1
}

resource "aws_route" "route2" {
  route_table_id = aws_route_table.vpc2-rtb.id
  destination_cidr_block = "10.0.0.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  provider = aws.ap-southeast-2
}

resource "aws_route" "route2-int" {
  route_table_id = aws_route_table.vpc2-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw2.id
  provider = aws.ap-southeast-2
}

resource "aws_route_table_association" "rtb1-asso" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.vpc1-rtb.id
  provider = aws.ap-southeast-1
}
resource "aws_route_table_association" "rtb2-asso" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.vpc2-rtb.id
  provider = aws.ap-southeast-2
}
resource "aws_security_group" "sg1" {
  name        = "public_sg1"
  description = "ICMP test"
  vpc_id      = aws_vpc.vpc1.id
  provider = aws.ap-southeast-1

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_security_group" "sg2" {
  name        = "public_sg2"
  description = "ICMP test"
  vpc_id      = aws_vpc.vpc2.id
  provider = aws.ap-southeast-2

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}