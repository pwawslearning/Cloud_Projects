# Create VPC and subnet
resource "aws_vpc" "znt_vpc" {
  cidr_block = "10.0.0.0/20"
  tags = {
    Name = "${var.project_name}"
  }
}
resource "aws_subnet" "public_subnet1a" {
  vpc_id            = aws_vpc.znt_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.az_a
  map_public_ip_on_launch = true
  tags = {
    Name = "pub_subnet1a"
  }
}
resource "aws_subnet" "public_subnet1b" {
  vpc_id            = aws_vpc.znt_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_b
  map_public_ip_on_launch = true
  tags = {
    Name = "pub_subnet1b"
  }
}

resource "aws_subnet" "private_subnet1a" {
  vpc_id            = aws_vpc.znt_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "pri_subnet1a"
  }
}
resource "aws_subnet" "private_subnet1b" {
  vpc_id            = aws_vpc.znt_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az_b

  tags = {
    Name = "pri_subnet1b"
  }
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.znt_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create route table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.znt_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rtb"
  }
}

resource "aws_route_table_association" "pub_sub1a_to_pub_rtb" {
  subnet_id      = aws_subnet.public_subnet1a.id
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_route_table_association" "pub_sub1b_to_pub_rtb" {
  subnet_id      = aws_subnet.public_subnet1b.id
  route_table_id = aws_route_table.public_rtb.id
}
#security group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allows web access HTTP from public"
  vpc_id      = aws_vpc.znt_vpc.id

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

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow HTTP, SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.znt_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

resource "aws_security_group" "db-sg" {
  name        = "database_sg"
  description = "Allow SQL inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.znt_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]

  }
}

# create key pair

resource "aws_key_pair" "keypair" {
  key_name   = "myan23-key"
  public_key = var.public_key
}


resource "aws_iam_role" "s3_role" {
  name = "s3access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.s3_role.name
  policy_arn = data.aws_iam_policy.s3_full_access.arn
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.znt_vpc.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_rtb.id]
}

resource "aws_launch_template" "web_template" {
  description            = "EC2 template for ASG"
  image_id               = var.instance_image
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.keypair.key_name
  user_data = filebase64("${path.module}/user_data.sh")
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  tags = {
    Name = "${var.project_name}"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.myan23_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
  }
  monitoring {
    enabled = true
  }
}

resource "aws_iam_instance_profile" "myan23_profile" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.s3_role.name
}

resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1a.id, aws_subnet.public_subnet1b.id]

}

resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.project_name}-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.znt_vpc.id
  tags = {
    Name = "${var.project_name}-TG"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
  port     = 80
  protocol = "HTTP"
}

resource "aws_autoscaling_group" "asg" {
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  name               = "${var.project_name}-ASG"
  vpc_zone_identifier = [aws_subnet.public_subnet1a.id, aws_subnet.public_subnet1b.id]
  target_group_arns  = [aws_lb_target_group.alb_tg.arn]
  launch_template {
    id = aws_launch_template.web_template.id
  }
}

#Creating database

resource "aws_db_subnet_group" "subnet_group" {
  name       = "db-subnetgroup"
  subnet_ids = [aws_subnet.private_subnet1a.id, aws_subnet.private_subnet1b.id]

  tags = {
    Name = "My DB subnet group"
  }
}

# create rds instances
resource "aws_db_instance" "db-instance" {
  identifier                = "mydb-instance"
  allocated_storage         = 10
  db_name                   = var.db_name
  engine                    = "mysql"
  engine_version            = "8.0.39"
  instance_class            = "db.t3.micro"
  username                  = var.db_username
  password                  = var.db_password
  storage_type              = "gp2"
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids    = [aws_security_group.db-sg.id]
  multi_az                  = true # for multi-DB instance
  publicly_accessible       = false
  final_snapshot_identifier = false
  backup_retention_period   = 2

  tags = { "Name" = "mydb-instance" }
}

resource "aws_db_instance" "read-replica" {
  replicate_source_db        = aws_db_instance.db-instance.identifier
  identifier                 = "read-replica"
  allocated_storage          = 10
  instance_class             = "db.t3.micro"
  storage_type               = "gp2"
  vpc_security_group_ids     = [aws_security_group.db-sg.id]
  multi_az                   = false
  publicly_accessible        = false
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true

  tags = { "Name" = "read-replica" }
}