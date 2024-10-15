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

  tags = {
    Name = "public_rtb"
  }
}
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXVs439ix8FA66ra6JcaUOUYVs2AitIsX6j/4Qvoh7Ij9ysOUXW5tpSXkDpK7t6s2QQXHs/raodVJ55LA12DewkisJ5Czc76rvldYS9rerAIW2bfhNGDQ5SxYUYmeak/UL8w8BWqvAsJrmufJ6TS2SDh2UxaKJJQJ3fJYXfpnWPPF4r7+wSwMg8pB4zSs+DXMYo15s820WlwcO5q9c2CMqhpggb/rJLA3+736zRY3tHyj4Qd8OQu9Y5dwecqs9hizKyRb6Ic4xe1S7IY7195KTqumLGoR/zZB+xtCy7M6loLtnCnV3ULXO1B/ey0F9vX3TTwMzHJ5Cw/LPjrQUUebgC0s1E1XhSPgjpHealZP5C8Xd3ecRI7PW60L6dLMCNJEUFG3R/crhJQAsAwzD/4sVCmtifAXJCecYoacLEEFfp83ktAcnJdh7pU8RFtDDOHSoSpIhheQr4i5NQP1hd3+yUUWu/t0ggPd1fUdAdiwRLdtHVNYqfNlZ9eES+6Wi2yk= phyowai@phyowai-Ubuntu"
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
resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.znt_vpc.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_rtb.id]
}

resource "aws_instance" "web_svr" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = aws_subnet.public_subnet1a.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.myan23_profile.name

  tags = {
    Name = "${var.project_name}"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/../.ssh/myan23_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "curl -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip",
      "sudo apt install -y unzip",
      "unzip awscliv2.zip",
      "sudo ./aws/install"
    ]
  }
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
resource "aws_rds_cluster" "cluster" {
  cluster_identifier      = "my-rds-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "13.7"  # Specify your PostgreSQL version
  master_username         = "admin"
  master_password         = "your-master-password"
  database_name           = "mydb"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true

  # Backup settings
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"

  # Maintenance settings
  preferred_maintenance_window = "sun:04:00-sun:06:00"
}

# Create RDS Cluster Instances
resource "aws_rds_cluster_instance" "example_instance_1" {
  identifier        = "my-rds-cluster-instance-1"
  cluster_identifier = aws_rds_cluster.example.id
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.example.engine

  # Associate instance with a subnet in AZ 'us-east-1a'
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}
