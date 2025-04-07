# Select instance image
data "aws_ami" "bh_image" {
    owners = ["amazon"]
    most_recent = true
      filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

#security group for bastion host
resource "aws_security_group" "bh-sg" {
  vpc_id = aws_vpc.vpc.id
  name = "${var.tags}-bh-sg"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate keypair to access bastion host
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = "4096"
}
resource "local_file" "private_key" {
  content = tls_private_key.ssh.private_key_openssh
  filename = "${path.root}/key/${var.tags}-key.pem"
  provisioner "local-exec" {
    command = "chmod 400 ${path.root}/key/${var.tags}-key.pem"
  }
}
resource "aws_key_pair" "key_pair" {
  key_name = "${var.tags}-keypair"
  public_key = tls_private_key.ssh.public_key_openssh
  tags = {
    Name = "${var.tags}_keypair"
  }
}

#Create bastion host instance
resource "aws_instance" "bastion" {
  subnet_id = aws_subnet.public_subnet01.id
  vpc_security_group_ids =[aws_security_group.bh-sg.id]
  ami = data.aws_ami.bh_image.id
  associate_public_ip_address = true
  key_name = aws_key_pair.key_pair.key_name
  instance_type = "t2.micro"
}