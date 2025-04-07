resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.vpc.id
  name = "${var.tags}-sg"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bh-sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tags}-sg"
  }
}

data "aws_ami" "blue-green-image" {
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

# Auto_scaling group for Blue environment
resource "aws_launch_template" "blue-template" {
  name = "blue-emplate"
  image_id = data.aws_ami.blue-green-image.id
  instance_type = "t2.micro"
  user_data = filebase64("${path.root}/userdata/blue.sh")
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "blue-template"
  }
}

resource "aws_autoscaling_group" "blue-asg" {
  name = "blue-asg"
  desired_capacity = 2
  min_size = 1
  max_size = 3
  vpc_zone_identifier = [aws_subnet.private-subnet01.id, aws_subnet.private-subnet02.id]
  target_group_arns = [aws_lb_target_group.blue-tg.arn]
  launch_template {
    name = aws_launch_template.blue-template.name
    version = "$Latest"
  }
}

# Auto_scaling group for Green environment
resource "aws_launch_template" "green-template" {
  name = "green-emplate"
  image_id = data.aws_ami.blue-green-image.id
  instance_type = "t2.micro"
  user_data = filebase64("${path.root}/userdata/green.sh")
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "green-template"
  }
}
resource "aws_autoscaling_group" "green-asg" {
  name = "green-asg"
  desired_capacity = 2
  min_size = 1
  max_size = 3
  vpc_zone_identifier = [aws_subnet.private-subnet01.id, aws_subnet.private-subnet02.id]
  target_group_arns = [aws_lb_target_group.green-tg.arn]
  launch_template {
    name = aws_launch_template.green-template.name
    version = "$Latest"
  }
}