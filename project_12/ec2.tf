data "aws_ami" "image" {
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

# Create Key pair
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

#Create security group
resource "aws_security_group" "web-sg" {
  vpc_id = aws_vpc.vpc.id
  name = "${var.tags}-bh-sg"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
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
resource "aws_instance" "web_svr" {
  ami = data.aws_ami.image.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web-sg.id]
  subnet_id = aws_subnet.public_subnet01.id
  key_name = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  depends_on = [ aws_security_group.web-sg ]

  provisioner "remote-exec" {
    connection {
      user = "ubuntu"
      host = self.public_ip
      type = "ssh"
      private_key = tls_private_key.ssh.private_key_pem
    }
    inline = [ 
        "sudo apt update -y",
        "sudo apt install apache2 -y",
        "echo '<h1>Hello World</h1>' | sudo tee /var/www/html/index.html",
        "sleep 10",  # Give it time to settle
        "sudo systemctl daemon-reexec",
        "sudo systemctl restart apache2",
     ]
  }
}
