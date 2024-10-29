output "vpc_name" {
  value = aws_vpc.znt_vpc.arn
}
output "instance_ip" {
  value = aws_instance.web_svr.public_ip
}
output "instance_dns" {
  value = aws_instance.web_svr.public_dns
}
output "master_db" {
  value = aws_db_instance.db-instance.endpoint
}
output "read_replica" {
  value = aws_db_instance.read-replica.endpoint
}