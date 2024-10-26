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

  tags = {
    Name = "pub_subnet1a"
  }
}
resource "aws_subnet" "public_subnet1b" {
  vpc_id            = aws_vpc.znt_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_b

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
  route = {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
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

# #Create S3 bucket and upload file
# resource "aws_s3_bucket" "myan23_bucket" {
#   bucket = "myan23-bucket01"

#   tags = {
#     Name        = "myan23-bucket01"
#   }
# }
# resource "aws_s3_bucket_ownership_controls" "object_ownership" {
#   bucket = aws_s3_bucket.myan23_bucket.id

#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }
# resource "aws_s3_object" "object" {
#   bucket = aws_s3_bucket.myan23_bucket.bucket
#   key    = "myan23"
#   source = "${path.module}"
# }

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

data "aws_ami" "instance_ami" {
  filter {
    name = "image_id"
    values = ["ami-03fa85deedfcac80b"]
  }
  filter {
    name = "platform"
    values = ["ubuntu"]
  }
  filter {
    name = "root_device_type"
    values = ["ebs"]
  }
}

resource "aws_instance" "web_svr" {
  ami                         = data.aws_ami.instance_ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = aws_subnet.public_subnet1a.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.myan23_profile.name

  tags = {
    Name = "${var.project_name}"
  }
  # connection {
  #   type        = "ssh"
  #   user        = "ubuntu"
  #   private_key = file("${path.module}/../.ssh/myan23_rsa")
  #   host        = self.public_ip
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt update",
  #     "curl -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip",
  #     "sudo apt install -y unzip",
  #     "unzip awscliv2.zip",
  #     "sudo ./aws/install"
  #   ]
  # }
}
resource "aws_iam_instance_profile" "myan23_profile" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.s3_role.name
}

#Creating database

resource "aws_db_subnet_group" "db-subnetgroup" {
  name       = "db-subnetgroup"
  subnet_ids = [aws_subnet.private_subnet1a.id, aws_subnet.private_subnet1b.id]

  tags = {
    Name = "My DB subnet group"
  }
}
# Create the RDS cluster
data "aws_rds_engine_version" "rds_engine_version" {
  engine             = "mysql"
  preferred_versions = ["8.0.39"]
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier      = "my-rds-cluster"
  engine                  = data.aws_rds_engine_version.rds_engine_version.engine
  engine_version          = data.aws_rds_engine_version.rds_engine_version.preferred_versions
  master_username         = var.db_username
  master_password         = var.db_password
  database_name           = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db-sg.id]
}

# Create RDS Cluster Instances
resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "db_instance-${count.index}"
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class     = "db.t3.micro"
  engine             = data.aws_rds_engine_version.rds_engine_version.engine
  engine_version     = data.aws_rds_engine_version.rds_engine_version.preferred_versions
}
