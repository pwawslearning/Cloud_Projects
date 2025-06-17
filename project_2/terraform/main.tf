#create vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "${var.project-name}-vpc"
  }
}

#create public subnets
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet1
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project-name}-public_subnet1"
  }
}


resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet2
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project-name}-public_subnet2"
  }
}


#create private subnets
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet1
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project-name}-private_subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet2
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project-name}-private_subnet2"
  }
}

#create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "my-vpc-igw"
  }
}

#create public route table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-rtb"
  }
}

resource "aws_route_table_association" "public_rtb_associate1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_route_table_association" "public_rtb_associate2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rtb.id
}

#create NAT gateway
resource "aws_eip" "eip_nat1" {
  domain = "vpc"
}

resource "aws_eip" "eip_nat2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.eip_nat1.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "nat-gateway1"
  }
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.eip_nat2.id
  subnet_id     = aws_subnet.public_subnet2.id

  tags = {
    Name = "nat-gateway2"
  }
}

resource "aws_route_table" "private_rtb1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }

  tags = {
    Name = "private_route_table1"
  }
}

resource "aws_route_table_association" "private_rtb_associate1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rtb1.id
}

resource "aws_route_table" "private_rtb2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }

  tags = {
    Name = "private_route_table2"
  }
}

resource "aws_route_table_association" "private_rtb_associate2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rtb2.id
}

#create security-groups
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allows web access HTTP from public"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allows Website acccess"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "web_svr_sg" {
  name        = "web_svr_sg"
  description = "Allows http from AlB"
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can limit this to specific IP ranges if needed
  }
  
  ingress {
    description = "allow HTTP via ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Create S3 bucket and endpoint gateway
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.project-name}-bucket02"

  tags = {
    Name = "${var.project-name}-bucket02"
  }
}
resource "aws_s3_bucket_ownership_controls" "object_ownership" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  key    = "index.html"
  source = "${path.module}/../html/index.html"
}
resource "aws_s3_object" "object_image" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  key    = "Apache.png"
  source = "${path.module}/../html/Apache.png"
}

# Creating s3-role
resource "aws_iam_role" "s3role" {
  name = "${var.project-name}-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
        }
      ]
  })
}
# attach s3 access policy to role
resource "aws_iam_role_policy_attachment" "s3role_policy_attachment" {
  role       = aws_iam_role.s3role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# attach SSM policy to role
resource "aws_iam_role_policy_attachment" "s3role_policy2_attachment" {
  role       = aws_iam_role.s3role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

#Create instance profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.project-name}-instance_profile"
  role = aws_iam_role.s3role.name
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rtb1.id, aws_route_table.private_rtb2.id]
}

#create ALB and ASG
resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.project-name}-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    enabled           = true
    healthy_threshold = 5
    interval          = 30
    timeout           = 5
    protocol          = "HTTP"
    path              = "/"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.project-name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  tags = {
    Name = "${var.project-name}-alb"
  }
}

resource "aws_lb_listener" "alb_listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_launch_template" "svr_template" {
  name                   = "${var.project-name}-template"
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_svr_sg.id]
  user_data              = filebase64("${path.module}/../html/config.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  tags = {
    Name = "${var.project-name}-template"
  }
}

resource "aws_autoscaling_group" "apache_asg" {
  name                = "${var.project-name}-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  target_group_arns   = [aws_lb_target_group.alb_tg.arn]

  launch_template {
    id      = aws_launch_template.svr_template.id
    version = "$Latest"
  }
}


