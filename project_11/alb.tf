resource "aws_security_group" "alb-sg" {
  vpc_id = aws_vpc.vpc.id
  name = "alb-sg"
  description = "allow HTTP traffics through ALB"
  ingress {
    description = "Allow HTTP Traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb_target_group" "blue-tg" {
  name = "blue-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  health_check {
    path = "/"
    healthy_threshold = 3
    enabled = true
    protocol = "HTTP"
    interval = 50
    timeout = 5
  }
}
resource "aws_lb_target_group" "green-tg" {
  name = "green-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  health_check {
    path = "/"
    healthy_threshold = 3
    protocol = "HTTP"
    enabled = true
    interval = 50
    timeout = 5
  }
}

resource "aws_lb" "lb" {
  name = "${var.tags}-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets = [aws_subnet.public_subnet01.id, aws_subnet.public_subnet02.id]
  tags = {
    Name = "${var.tags}-alb"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"
  # Initially traffic forward to Blue environment
  # default_action {
  #   type = "forward"
  #   target_group_arn = aws_lb_target_group.blue-tg.arn
  # }
  # Shift the traffic to Green environment
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.green-tg.arn
  }
}