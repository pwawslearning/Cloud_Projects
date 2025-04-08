resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags       = {
    Name = "${var.tags}-vpc"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "public_subnet01" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block,9,0)
  tags = {
    Name = "${var.tags}-publicsubnet01"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tags}-igw"
  }
}
resource "aws_eip" "eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "${var.tags}-eip"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "assoc-rtb" {
  route_table_id = aws_route_table.rtb.id
  subnet_id = aws_subnet.public_subnet01.id
}

resource "aws_iam_role" "cloudwatch_vpc-flowlogs-role" {
  name = "cloudwatch_vpc-flowlogs-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "vpc-flow-logs.amazonaws.com"
          },
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  role = aws_iam_role.cloudwatch_vpc-flowlogs-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_flow_log" "vpc-flow-log" {
  vpc_id = aws_vpc.vpc.id
  log_destination = aws_cloudwatch_log_group.cw_log_group.arn
  traffic_type = "ALL"
  iam_role_arn = aws_iam_role.cloudwatch_vpc-flowlogs-role.arn
}