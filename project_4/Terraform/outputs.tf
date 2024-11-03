output "vpc_name" {
  value = aws_vpc.znt_vpc.arn
}
output "alb-dns" {
  value = aws_lb.web_alb.dns_name
}
output "master_db" {
  value = aws_db_instance.db-instance.endpoint
}
output "read_replica" {
  value = aws_db_instance.read-replica.endpoint
}