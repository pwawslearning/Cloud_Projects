resource "aws_instance" "web1" {
  ami = "ami-0b5a4445ada4a59b1"
  instance_type = "t2.micro"
  provider = aws.ap-southeast-1
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.sg1.id]

  tags = {
    Name = "web1"
  }
}
resource "aws_instance" "web2" {
  ami = "ami-0013d898808600c4a"
  instance_type = "t2.micro"
  provider = aws.ap-southeast-2
  subnet_id = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.sg2.id]
  
  tags = {
    Name = "web2"
  }
}