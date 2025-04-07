output "lb_dns" {
  value = aws_lb.lb.dns_name
}
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}